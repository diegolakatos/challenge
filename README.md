# Description
To fullfill the challenge I used a combination of terraform and ansible. This will create 5 machines: 1 elasticsearch server, 1 logstash server, 1 kibana server, 1 bastion host, 1 nginx proxy, also will create a Route 53 private zone, 2 subnets (1 private, 1 public), some security groups, and a ssh key-pair that is used to configure and access the instances. The region that is used is us-east-1.

# Instructions
To execute the code you must clone this repo and edit the following files:


- terraform_install_elk.tf : Please fill the fields access_key and secret_key with the credentials of an IAM user which have permissions to create the itens mentioned earlier. When I tried to use a variable to provide this parameter, using both a configuration file and passing the parameter on the command, I hit the issue described in https://github.com/hashicorp/terraform/issues/13040



The access_key and secret_key should be configured as the example below (the credentials below doesn't work):  




provider "aws" {  
  access_key = "AOfNAJP5SGSWF6BRTXGJ7"  
  secret_key = "2D0nMj756YXQf383uqfgnMj756YXQC1Ti"  
  region     = "us-east-1"  
}  

- vars.tf : To change the IPs that are allowed to send logs to logstash, for example  
variable "ip" {  
  type    = "list"  
  default = ["192.167.9.32/32", "10.0.0.0/16"]  
}  

### Verify if the ssh-keys have the correct permissions (only the owner can read or write, group and others should not have access)

On the folder that contains the files from the repo just use the command  
terraform apply  

After the execution is finished you can access the kibana dashboard using the public IP of the instance "kibanaproxy" the proxy will request a username and password:  
username: kibanaadmin  
password: challenge  

To connect on the instances use private key provided on this repo (this key will only work in the machines created by the code of this repo)  
