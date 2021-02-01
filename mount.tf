resource "aws_efs_file_system" "efs" {
  creation_token   = "efs-data"
  performance_mode = "generalPurpose"
  encrypted        = "true"
tags = {
    Name = "EFS Data Volume"
  }
}
resource "aws_efs_mount_target" "efs" {                      
  file_system_id  = aws_efs_file_system.efs.id
  count = length(var.azs)
  subnet_id        = aws_subnet.private[count.index].id
  security_groups =  [aws_security_group.web_ec2.id]       
}

resource "aws_ebs_encryption_by_default" "enabled" {
 enabled = true
  }
