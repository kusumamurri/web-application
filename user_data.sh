#! /bin/bash
sudo yum update -y
sudo yum install -y httpd.x86_64
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1><font color="green"> Sessionm		 </font></h1> <hr>  <h3> Kusuma Murri </h3>" >  /var/www/html/index.html    


yum install -y amazon-efs-utils
mkdir /efs
efs_id="${efs_id}"
mount -t efs $efs_id:/ /efs
echo $efs_id:/ /efs efs defaults,_netdev 0 0 >> /etc/fstab
