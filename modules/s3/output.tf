#output s3

output "s-3" {
  value = "${aws_s3_bucket.bucketfordynamo.id}"
}
output "s-3-key-post" {
  value = "${aws_s3_bucket_object.mybucket-for-lambda-dynamodb-post.key}"
}

output "s-3-object-post" {
  value = "${aws_s3_bucket_object.mybucket-for-lambda-dynamodb-post.name}"
}

output "s-3-key-get" {
  value = "${aws_s3_bucket_object.mybucket-for-lambda-dynamodb-get.key}"
}

output "s-3-object-get" {
  value = "${aws_s3_bucket_object.mybucket-for-lambda-dynamodb-get.name}"
}
