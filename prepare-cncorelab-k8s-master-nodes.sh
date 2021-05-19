#!/bin/bash

#Set proxy
export https_proxy=10.64.1.81:8080

#Set “swat-off -a”, otherwise kube service will not be started appropriately after work node machine restarted
# 1. https://blog.csdn.net/u010420283/article/details/105095811
# 2. How to run script at machine started: 
#     1. https://www.jianshu.com/p/79d24b4af4e5
# run script: "ubuntu18-bootstart-setting.sh"


#Add default gw, use 192.168.0.250, which can access 10.64.1.81:8080 tw proxy. 0.254 could not access proxy… pre-created ubuntu18 image used 0.254
route add default gw 192.168.0.250
route delete default gw 192.168.0.254