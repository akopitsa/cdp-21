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
  source               = "./modules/apigateway"
  region               = "${var.region}"
  lambda-get-arn       = "${module.lambda.lambda-get-arn}"
  lambda-post-arn      = "${module.lambda.lambda-post-arn}"
  lambda-post-function = "${module.lambda.lambda-post-function}"
  lambda-get-function  = "${module.lambda.lambda-get-function}"
  account_id           = "${module.lambda.account_id}"
}
