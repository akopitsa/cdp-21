# S3 MODULE main.tf

resource "aws_s3_bucket" "bucketfordynamo" {
  bucket = "mybucket-for-lambda-dynamodb-with-api-gateway"
  acl    = "private"

  versioning {
    enabled = true
  }

  region = "${var.region}"
}

resource "aws_s3_bucket_object" "mybucket-for-lambda-dynamodb-get" {
  bucket = "${aws_s3_bucket.bucketfordynamo.bucket}"

  //count = "${length(var.files)}"
  acl    = "private"
  key    = "HelloLampdaGet.zip"
  source = "${var.path_to_file}/HelloLampdaGet.zip"

  //etag   = "${md5(file("/Users/andrey.kopitsa/eclipse-workspace/HelloLambda/build/distributions/HelloLambda.zip"))}"
  tags {
    Name = "mybucket-for-lambda-function"
  }
}

resource "aws_s3_bucket_object" "mybucket-for-lambda-dynamodb-post" {
  bucket = "${aws_s3_bucket.bucketfordynamo.bucket}"

  //count = "${length(var.files)}"
  acl    = "private"
  key    = "HelloLambda.zip"
  source = "${var.path_to_file}/HelloLambda.zip"

  //etag   = "${md5(file("/Users/andrey.kopitsa/eclipse-workspace/HelloLambda/build/distributions/HelloLambda.zip"))}"
  tags {
    Name = "mybucket-for-lambda-function"
  }
}
