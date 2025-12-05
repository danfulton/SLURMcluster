#!/bin/bash
#


sudo cp /share/apparmor.profile /etc/apparmor.d/enroot
sudo aa-complain /usr/bin/enroot-nsenter
sudo aa-complain /etc/apparmor.d/*
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
echo 'kernel.apparmor_restrict_unprivileged_userns=0' | sudo tee -a /etc/sysctl.d/99-enroot.conf
sudo apparmor_parser -R /etc/apparmor.d/enroot

