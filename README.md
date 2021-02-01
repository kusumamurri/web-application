# web-application
Launches an application server using terraform
# web-application
Launches an application server using terraform

VPC named "web-production"  with CIDR 10.0.0.0/16 and  internet gateway is created.
Created both public and private subnets in all the availability zones
Route tables were created and assosciated to subnets
natgateway is created and assosciated

Application Load balancer is created in public subnets
Web server ASG is deployed in private subnets with restricted security groups

Efs is mounted on /efs 

Files:
  alarm.tf          - health check alarm
  asg.tf            - ALB, ASG, security groups etc.,
	ec2.tf            - Latest image and security group for instances
	mount.tf          - EFS creation, mount and encryption
	notification.tf   - sns notification and subscription
	provider.tf       - provider AWS
	user_data.sh      - userdata for EC2 instance launch configuration
	vars.tf           - list of variables used 
	vpc.tf            - vpc , subnets, eip, gateways etc., and its assosciations
  
Input:
  configure aws cli with access key and secret key
  
* IMP: please provide variable "key" in vars.tf file
  mail id , aws_access_key, aws_secret_key  can be given while executing terraform command or can be given in vars.tf file as well.
  
  
  


