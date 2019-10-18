provider "aws" {
  region = "us-east-1"
}

module vpc {
  source = "./modules/vpc"
}

module keypair {
  source = "./modules/keypair"
}

module elasticsearch {
  source = "./modules/ec2"
  vpc_id = "${module.vpc.vpc_id}"
  key_pair = "${module.keypair.key_name}"
  subnet_id = "${module.vpc.private_subnets}"
  app_name = "elasticsearch"
}