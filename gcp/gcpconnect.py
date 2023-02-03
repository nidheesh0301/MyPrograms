 
import os


import os

check_dis_size="/Users/I502493/Downloads/Softwares/google-cloud-sdk/bin/gcloud compute disks  list | egrep -i 'd01 | Name' | tail"
size=os.system(check_dis_size)
print(size)



