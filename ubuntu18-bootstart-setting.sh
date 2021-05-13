#!/bin/bash

cat <<EOF >/etc/systemd/system/rc-local .service
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local
 
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
 
[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
echo "看到这行字，说明添加自启动脚本成功。" > /usr/local/test.log

# swapoff, otherwise kubelet service could not started after node machine restarted
swapoff -a
exit 0
EOF

sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local

sudo systemctl start rc-local.service
sudo systemctl status rc-local.service

#check the test log if the start settings in "/etc/rc.local" applied
#cat /usr/local/test.log