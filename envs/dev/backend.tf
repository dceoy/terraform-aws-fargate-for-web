terraform {
  backend "s3" {
    encrypt = true
    # bucket         = ""
    # key            = ""
    # region         = "us-east-1"
    # dynamodb_table = ""
  }
}
