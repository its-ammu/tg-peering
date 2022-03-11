provider "aws" {
    region = "us-east-1"
}

provider "aws" {
    alias = "region2"
    region = "us-west-1"
}