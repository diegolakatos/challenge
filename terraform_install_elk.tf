provider "aws" {
  access_key = "XXXXXXX"
  secret_key = "XXXXXXX"
  region     = "us-east-1"
}

resource "aws_vpc" "elk_stack" {
  cidr_block = "192.168.108.0/24"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"
}

resource "aws_internet_gateway" "igw_elk_stack" {
  vpc_id = "${aws_vpc.elk_stack.id}"
}

resource "aws_subnet" "elk_stack-public" {
  vpc_id                  = "${aws_vpc.elk_stack.id}"
  cidr_block              = "192.168.108.0/26"
  availability_zone		  = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "elk_stack-private" {
  vpc_id                  = "${aws_vpc.elk_stack.id}"
  cidr_block              = "192.168.108.64/26"
  availability_zone		  = "us-east-1b"
  map_public_ip_on_launch = false
}

resource "aws_route" "internet_access" {
 route_table_id         = "${aws_vpc.elk_stack.main_route_table_id}"
 destination_cidr_block = "0.0.0.0/0"
 gateway_id             = "${aws_internet_gateway.igw_elk_stack.id}"
}


resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.elk_stack.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.elk_nat.id}"
  }

  tags {
    Name = "nat"
  }
}


resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.elk_stack-private.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_eip" "eip_nat" {
  vpc      = true
}

resource "aws_nat_gateway" "elk_nat" {
  #vpc_id = "${aws_vpc.elk_stack.id}"
  allocation_id  = "${aws_eip.eip_nat.id}"
  depends_on = ["aws_internet_gateway.igw_elk_stack"]
  subnet_id = "${aws_subnet.elk_stack-public.id}"
}

resource "aws_security_group" "SG_all" {
  name        = "SG_all"
  description = "SG for all instances"
  vpc_id      = "${aws_vpc.elk_stack.id}"

  # Full access from bastion host

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self = "true"
  }


# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG_kibana" {
  name        = "SG_kibana"
  description = "SG for kibana"
  vpc_id      = "${aws_vpc.elk_stack.id}"

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["192.168.108.0/26"]
  }
# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG_elasticsearch" {
  name        = "SG_elasticsearch"
  description = "SG for elastic search"
  vpc_id      = "${aws_vpc.elk_stack.id}"



  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["192.168.108.0/26"]
  }

ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "udp"
    cidr_blocks = ["192.168.108.0/26"]
  }

ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["192.168.108.64/26"]
  }
ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "udp"
    cidr_blocks = ["192.168.108.64/26"]
  }

# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "SG_bastion" {
  name        = "SG_bastion"
  description = "SG for bastion host"
  vpc_id      = "${aws_vpc.elk_stack.id}"

  # Full access from bastion host

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG_logstash" {
  name        = "SG_logstash"
  description = "SG for elastic search"
  vpc_id      = "${aws_vpc.elk_stack.id}"

 ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = ["${var.ip}"] 
  }
 
 ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = ["192.168.108.0/26"]
  }

ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["${var.ip}"] 
  }
 
 ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["192.168.108.0/26"]
  }

# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG_kibanaproxy" {
  name        = "SG_kibanaproxy"
  description = "SG for proxy"
  vpc_id      = "${aws_vpc.elk_stack.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "terra_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLqvakspaRtsGjtl874D2v3k4rPGfHO5KSGeN0ZJ4/Oyyw1ql5ttxJmjexQLP89SgIZp1NwHt2uJELIneH306FuK4WEDojy//tCUs4zhpJEhMh/JyK0WYRnGETPI1Y6ACMosINV98aPkrEXNUkGM5kGHQZLvunYhsGov9SqvNR8Dn7MdlQM+EBKo0j33tX6yRDeFatYC6bfXN5nhIAxjumBeTTg0ccNT5egSeRGODU9zV2DZsC3otCABtzH/iIdRnso0lbupGrTp1FQ2dAQQES5mCjYyAbsTGK1wxwNgZNllbTK8UZXjJG1J+xPcEb/zkHc+KglLdEG93E51fyCEgjjbTUoNF7Ho/XGq12gQSL0ntLRKi2tM24kTsZalSk63SETxmSZLbfn/2Sfl/uXjWI6Mtu4TaQRL5G2ZzRbb6ZEwxMxCuLmVRJmotBsEYC35JNCbKGJlUlKg83s8LbNBEfI6UYWKQdUJMun1PcDzhrsDuXB9mwpTdRphcModrhAwbGZYssHg98hZFeRsq2gTp+B2EczGhtnXigl/IjvtbY9hqy5HZONS1bFARkF0GvITGLEQr6mORkVBuE6m12nbWVQjfKO4eotc5rzC18N89KybdK3fAlmmGTCXDQPeVFdU10y+MyEowHjoqmJQt21OxkoCZC/5LdzHAuFu/rK1z6Xw== diego@diego-VirtualBox"
}


resource "aws_instance" "bastion" {
  ami = "ami-ae7bfdb8"
  #ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.nano"
  key_name = "terra_key"
  vpc_security_group_ids = ["${aws_security_group.SG_all.id}" , "${aws_security_group.SG_bastion.id}"]
  subnet_id = "${aws_subnet.elk_stack-public.id}"
  tags {
	  Name = "bastion"
  }
	}


resource "aws_instance" "elasticsearch" {
  ami = "ami-ae7bfdb8"
  #ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.large"
  key_name = "terra_key"
  vpc_security_group_ids = ["${aws_security_group.SG_all.id}" , "${aws_security_group.SG_elasticsearch.id}"] 
  subnet_id = "${aws_subnet.elk_stack-private.id}"
  tags {
	  Name = "elasticsearch"
  }
	provisioner "remote-exec" {

	 connection {
   		type     = "ssh"
    	user     = "centos"
		private_key = "${file("/home/diego/.ssh/id_rsa")}"
		bastion_host = "${aws_instance.bastion.public_ip}"
		timeout = "60m"
  }

	inline = [
		"sudo yum install -y git epel-release",
		"sudo yum update -y",
		"sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch",
		"sudo yum install -y ansible",
		"sudo echo '${aws_instance.elasticsearch.private_ip}' elasticsearch.lakatos.com",
		"ansible-pull -U https://github.com/diegolakatos/challenge -i 'hosts.yml' -d /home/centos/ansible_execute install_elasticsearch.yml",
	]
}
}

resource "aws_instance" "kibana" {
  ami = "ami-ae7bfdb8"
  #ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.large"
  key_name = "terra_key"
  vpc_security_group_ids = ["${aws_security_group.SG_all.id}" , "${aws_security_group.SG_kibana.id}"] 
  subnet_id = "${aws_subnet.elk_stack-private.id}"
  tags {
	  Name = "kibana"
  }
	provisioner "remote-exec" {

	 connection {
   		type     = "ssh"
    	user     = "centos"
		private_key = "${file("/home/diego/.ssh/id_rsa")}"
		bastion_host = "${aws_instance.bastion.public_ip}"
		timeout = "60m"
  }

	inline = [
		"sudo setenforce 0",
		"sudo yum install -y git epel-release",
		"sudo yum update -y",
		"sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch",
		"sudo yum install -y ansible",
		"ansible-pull -U https://github.com/diegolakatos/challenge -i 'hosts.yml' -d /home/centos/ansible_execute install_kibana.yml",
	]
}
} 

resource "aws_instance" "logstash" {
  ami = "ami-ae7bfdb8"
  #ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.large"
  key_name = "terra_key"
  vpc_security_group_ids = ["${aws_security_group.SG_all.id}" , "${aws_security_group.SG_logstash.id}"]
  subnet_id = "${aws_subnet.elk_stack-public.id}"
  tags {
	  Name = "logstash"
  }
	provisioner "remote-exec" {

	 connection {
   		type     = "ssh"
    	user     = "centos"
		private_key = "${file("/home/diego/.ssh/id_rsa")}"
		bastion_host = "${aws_instance.bastion.public_ip}"
		host = "${aws_instance.logstash.private_ip}"
		timeout = "60m"
		
  }

	inline = [
		"sudo yum install -y git epel-release",
		"sudo yum update -y",
		"sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch",
		"sudo yum install -y ansible",
		"ansible-pull -U https://github.com/diegolakatos/challenge -i 'hosts.yml' -d /home/centos/ansible_execute install_logstash.yml",
	]
}
} 

resource "aws_instance" "kibanaproxy" {
  ami = "ami-ae7bfdb8"
  #ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "terra_key"
  vpc_security_group_ids = ["${aws_security_group.SG_all.id}" , "${aws_security_group.SG_kibanaproxy.id}"]
  subnet_id = "${aws_subnet.elk_stack-public.id}"
  tags {
	  Name = "kibanaproxy"
  }
	provisioner "remote-exec" {

	 connection {
   		type     = "ssh"
    	user     = "centos"
		private_key = "${file("/home/diego/.ssh/id_rsa")}"
		bastion_host = "${aws_instance.bastion.public_ip}"
		host = "${aws_instance.kibanaproxy.private_ip}"
		timeout = "60m"
  }

	inline = [
		"sudo setenforce 0",
		"sudo yum install -y git epel-release",
		"sudo yum update -y",
		"sudo yum install -y ansible",
		"ansible-pull -U https://github.com/diegolakatos/challenge -i 'hosts.yml' -d /home/centos/ansible_execute install_nginx.yml",
	]
}
}


resource "aws_route53_zone" "lakatos" {
  name = "lakatos"
  vpc_id  = "${aws_vpc.elk_stack.id}"
}

resource "aws_route53_record" "elasticsearch" {
  zone_id = "${aws_route53_zone.lakatos.zone_id}"
  name    = "elasticsearch.lakatos"
  type    = "A"
  ttl     = "60"
  records = ["${aws_instance.elasticsearch.private_ip}"]
}
resource "aws_route53_record" "kibanaserver" {
  zone_id = "${aws_route53_zone.lakatos.zone_id}"
  name    = "kibanaserver.lakatos"
  type    = "A"
  ttl     = "60"
  records = ["${aws_instance.kibana.private_ip}"]
}
resource "aws_route53_record" "logstash" {
  zone_id = "${aws_route53_zone.lakatos.zone_id}"
  name    = "logstash.lakatos"
  type    = "A"
  ttl     = "60"
  records = ["${aws_instance.logstash.private_ip}"]
}
