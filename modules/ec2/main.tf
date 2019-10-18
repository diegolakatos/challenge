data "aws_region" "current" {}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "describe_instances" {
  name = "DescribeInstances"
  role = "${aws_iam_role.default_iam_role.id}"

  policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [{
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeInstances"
        ],
        "Resource": "*"
      }
     ]
}
EOF
}

resource "aws_iam_role" "default_iam_role" {
  name               = "aws-${var.environment}-${var.app_name}-role"
  assume_role_policy = "${data.aws_iam_policy_document.instance_assume_role_policy.json}"
}

resource "aws_iam_instance_profile" "default_instance_profile" {
  name = "aws-${var.environment}-${var.app_name}-profile"
  role = "${aws_iam_role.default_iam_role.name}"
}

resource "aws_security_group" "instance_security_group" {
  name   = "aws-${var.environment}-${var.app_name}-sg"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_rdp" {
  count       = "${var.allow_rdp ? 1 : 0}"
  type        = "ingress"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.instance_security_group.id}"
}

resource "aws_security_group_rule" "allow_ssh" {
  count       = "${var.allow_ssh ? 1 : 0}"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.instance_security_group.id}"
}

resource "aws_security_group_rule" "allow_http" {
  count       = "${var.allow_http ? 1 : 0}"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.instance_security_group.id}"
}

resource "aws_security_group_rule" "allow_https" {
  count       = "${var.allow_http ? 1 : 0}"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.instance_security_group.id}"
}

resource "aws_security_group_rule" "egress_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.instance_security_group.id}"
}

resource "aws_instance" "ec2_generic_instance" {
  count = "${var.number_of_instances}"

  //ami                         = "${lookup(lookup(var.ami_type, var.amis), data.aws_region.current.name)}"
  ami                         = "${lookup(var.aws_amis, "${var.ami_type}.${data.aws_region.current.name}")}"
  key_name                    = "${var.key_pair}"
  subnet_id                   = "${var.subnet_id}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = "${var.attach_eip ? var.attach_eip : var.public_ip}"
  iam_instance_profile        = "${aws_iam_instance_profile.default_instance_profile.id}"
  user_data                   = "${var.user_data_file}"

  root_block_device {
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.instance_security_group.id}",
    "${var.default_security_groups}",
  ]

  tags {
    Name        = "aws-${var.environment}-${var.app_name}"
    Environment = "${var.environment}"
    Backup      = "${var.backup}"
    Application = "${var.app_name}"
  }
}

resource "aws_eip" "instance_eip" {
  count                     = "${var.attach_eip ? 1 : 0}"
  vpc                       = true
  instance                  = "${element(aws_instance.ec2_generic_instance.*.id,count.index)}"
  associate_with_private_ip = "${element(aws_instance.ec2_generic_instance.*.private_ip,count.index)}"
}
