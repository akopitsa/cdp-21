# ROOT - MAIN TF
provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

module "s3" {
  source = "./modules/s3"
}

module "lambda" {
  source          = "./modules/lambda"
  s-3             = "${module.s3.s-3}"
  s-3-key-post    = "${module.s3.s-3-key-post}"
  s-3-object-post = "${module.s3.s-3-object-post}"
  s-3-key-get     = "${module.s3.s-3-key-get}"
  s-3-object-get  = "${module.s3.s-3-object-get}"
}

module "apiGW" {
  source = "./modules/apigateway"
}
