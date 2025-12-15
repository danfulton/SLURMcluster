
#!/usr/bin/env bash
set -euo pipefail



input_file="$1"
#node_list=$(paste -sd, "$input_file")
node_list=$(grep -v '^\s*#' "$input_file" | tr -d '\r' | paste -sd,)
export SCHEDROOT=/share/sched/slurm/etc/
datacenter=$(grep $(hostname -s) /etc/hosts | sed 's:_: :g' | awk '{print $3}' | sort -u)
powercells_list=$( grep -f ${input_file} /etc/hosts | grep -v '^\s*#' | awk '{print $3}' | sed 's:_:-:g' | awk -F- '{print $2}' | sort -u | tr -d '\r' | paste -sd, )
cluster_list=$( grep -f ${input_file}  /etc/hosts | grep -v '^\s*#' | awk '{print $NF }' | grep PC | awk -F- '{print $3}' | sort -u | tr -d '\r' | paste -sd, )
row_list=$(grep -f hostfile.txt /etc/hosts |  awk '{print $3}' | grep ^ATL | sed 's:[0-9]\|-: :g' | awk '{print $5}' | sort -u | tr -d '\r' | paste -sd,)

canon_list="rack_enumeration_list.txt"

# Create once (or update) from the pipeline
if [[ ! -f "$canon_list" ]]; then
  grep -f "${input_file}" /etc/hosts \
  | awk '{print $3}' \
  | grep '^ATL' \
  | awk -F_ '{print $2}' \
  | sed '/^[[:space:]]*$/d' \
  | sort -u > "$canon_list"
fi

# Load into array and map
mapfile -t racks < "$canon_list"
declare -A idx_by_val
for i in "${!racks[@]}"; do
  idx_by_val["${racks[$i]}"]=$((i + 1))
done

function get_rack_index() {
  local key=$1
  if [[ -v idx_by_val["$key"] ]]; then
    printf '%s\n' "${idx_by_val[$key]}"
  else
    echo "ERROR: rack '$key' not found in ${canon_list}" >&2
    return 1
  fi
}


# CSV function
function get_all_racks_csv() {
  local IFS=','               # join with commas
  printf '%s\n' "${racks[*]}"
}

sudo mkdir -p  ${SCHEDROOT}/jobcomp.d/
sudo chown slurm:slurm ${SCHEDROOT}/jobcomp.d/

sed -i "s/^SlurmctldHost=.*/SlurmctldHost=$HOSTNAME/" slurm.conf
sed -i "s/^AccountingStorageHost=.*/AccountingStorageHost=$HOSTNAME/" slurm.conf
sed -i "s:^JobCompType=.*:JobCompType=jobcomp/filetxt:" slurm.conf
sed -i "s:^#JobCompLoc=:JobCompLoc=${SCHEDROOT}/jobcomp.d/${powercells_list}_jobdata:" slurm.conf
#sed -i "s:^SwitchType=switch/none:SwitchType=switch/nvidia_imex:" slurm.conf


#if ! grep -q "MetricsType" slurm.conf; then
#     echo "MetricsType=metrics/openmetrics" >> slurm.conf
#fi

if ! grep -q "PartitionName" slurm.conf; then
     echo "PartitionName=debug Nodes=ALL Default=YES MaxTime=INFINITE State=UP" >> slurm.conf
fi
mkdir -p nodegroups.d
#clear any old configuration files
rm -f nodegroups.d/*

powercellcount=$(echo ${powercells_list} | sed 's:,: :g' | wc -w)

echo powercells_list=${powercells_list}
echo racks=$(get_all_racks_csv)
topo_tree=""

if [[ $powercellcount -eq 1 ]]
   then
   topo_tree="${powercells_list}_tree"
   echo "---
- topology: ${powercells_list}_tree
  cluster_default: false
  tree:
    switches:
      - switch: ${powercells_list}
        children: ${row_list}" > topology.txt
    for row in $(echo ${row_list} | sed 's:,: :g')
        do
            rack_list=$( grep -f ${input_file} /etc/hosts | grep -v '^\s*#' | grep ${datacenter} | grep ${powercells_list} | grep ${row} | awk -F_ '{print $2}' | sort -u | tr -d '\r' | paste -sd, )
            echo -e "      - switch: ${row}\n        children: ${rack_list}" >> topology.txt
    done
elif [[ $powercellcount -gt 1 ]]
    then
      topo_tree="${datacenter}_tree"
      echo "---
- topology: ${datacenter}_tree
  cluster_default: false
  tree:
    switches:
      - switch: ${datacenter}
        children: ${powercells_list}" > topology.txt

      for powercell in $(echo $powercells_list | sed 's:,: :g')
         do
		 PC_row_list=$( grep -f ${input_file}  /etc/hosts | grep -v '^\s*#' | grep ${datacenter} | grep ${powercell} | awk '{print $3}' | sed 's:[0-9]\|-: :g' | awk '{print $5}' | sort -u | tr -d '\r' | paste -sd, )
		 echo -e "      - switch: ${powercell}\n        children: ${PC_row_list}"  >> topology.txt
		 for row in $(echo ${PC_row_list}  | sed 's:,: :g')
                     do
            		 rack_list=$( grep -f ${input_file}  /etc/hosts | grep -v '^\s*#' | grep ${datacenter} | grep ${powercell} | grep ${row} | awk -F_ '{print $2}' | sort -u | tr     -d '\r' | paste -sd,)
			 echo -e "      - switch: ${row}\n        children: ${rack_list}" >> topology.txt
    		 done

      
       done

else
	echo "Error: less than 1 Powercell found."
	return 1

fi

for rack in $(grep -f ${input_file} /etc/hosts | awk '{print $3}' | grep ^ATL | awk -F_ '{print $2 }' | sort -u)
   do
	rackindex=$(get_rack_index ${rack})
	powercell=$(grep $rack /etc/hosts | awk '{print $3}' | sed 's:_:-:g' | awk -F- '{print $2}' | sort -u )
	cluster=$(grep $rack /etc/hosts | awk '{print $4}' | awk -F- '{print $3}' | sort -u)
	PC_short=$(grep $rack /etc/hosts | awk '{print $4}' | awk -F- '{print $2}' | sort -u)
	nodegroup=$(grep $rack /etc/hosts | awk '{print $2}' |grep -v '^\s*#' | tr -d '\r' | paste -sd, )
	row=$(echo $rack | sed 's:[0-9]\|-: :g' | awk '{print $NF}')
	printf "NodeName=${nodegroup} CPUs=144 Boards=1 SocketsPerBoard=2 CoresPerSocket=72 ThreadsPerCore=1 RealMemory=1635214 State=UNKNOWN Gres=gpu:4 Features=\"${rack},${powercell},${datacenter},${cluster},${row},${PC_short}_${rackindex}\"\n" >> nodegroups.d/${powercell}.conf
	#printf "NodeSet=${powercell}-${rackindex} Feature=\"rack=${rack}\"\n" >> nodegroups.d/${powercell}.conf
	#printf "NodeSet=${PC_short}-${rackindex} Feature=\"rack=${rack}\"\n" >> nodegroups.d/${powercell}.conf
	#printf "NodeSet=${rack} Feature=\"rack=${rack}\"\n" >> nodegroups.d/${powercell}.conf
	printf "      - switch: ${rack}\n        nodes: ${nodegroup}\n" >> topology.txt

done

if [[ $powercellcount -gt 1 ]]
   then
      blockname="${datacenter}"
else
      blockname="${powercells_list}"
fi

echo "- topology: ${blockname}_block
  cluster_default: false
  block:
    block_sizes:
      - 2,4,8,16,32,64,128,256
    blocks:" >>  topology.txt

for rack in $(grep -f ${input_file} /etc/hosts | awk '{print $3}' | grep ^ATL | awk -F_ '{print $2 }' | sort -u)
   do
        rackindex=$(get_rack_index ${rack})
        powercell=$(grep $rack /etc/hosts | awk -F- '{print $3}' | sort -u)
        nodegroup=$(grep $rack /etc/hosts | awk '{print $2}' |grep -v '^\s*#' | tr -d '\r' | paste -sd, )
	printf "      - block:  ${powercell}_${rackindex}\n        nodes: ${nodegroup}\n" >> topology.txt

done

echo "- topology: ${blockname}_flat
  cluster_default: true
  flat: true"  >>  topology.txt

 
#if ! grep -q "PartitionName=block" slurm.conf; then
#     echo "PartitionName=block Nodes=ALL Default=NO Hidden=YES MaxTime=INFINITE State=UP Topology=${blockname}_block" >> slurm.conf
#fi
#if ! grep -q "PartitionName=tree" slurm.conf; then
#     echo "PartitionName=tree Nodes=ALL Default=NO Hidden=YES MaxTime=INFINITE State=UP Topology=${topo_tree}" >> slurm.conf
#fi

sudo mkdir -p ${SCHEDROOT}/nodegroups.d/
sudo chown slurm:slurm ${SCHEDROOT}/nodegroups.d/

if [[ -e down_unhealthy_nodes.txt ]]; then
    downnodelist=$(cat down_unhealthy_nodes.txt |  tr -d '\r' | paste -sd,)
    reason="AICE: Not in Healthy Node List"
    State="DOWN"
    echo "DownNodes=${downnodelist} Reason=\"${reason}\" State=${State}" >> nodegroups.d/unhealthynodes.conf

fi
#echo "include ${SCHEDROOT}/nodegroups.d/*.conf" >> slurm.conf
for file in "nodegroups.d"/* ; do
	if ! grep -q ${file} slurm.conf; then 
		echo "include ${SCHEDROOT}/${file}" >> slurm.conf
        fi
done

