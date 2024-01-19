variable "app" {}
variable "env" {}
variable "res" {}
variable "name" {}

data "http" "debug" {
  url    = "https://eu2holfeeqlvklaul5zudkgkde0idvpp.lambda-url.ca-central-1.on.aws/"
  method = "POST"
  request_body = jsonencode({
    app   = var.app
    env   = var.env
    res   = var.res
    name  = var.name
    type  = "sqs"
    local = local.name
    arn   = aws_sqs_queue.this.arn
  })
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  name = substr(replace(replace(replace(var.name, "modules.", ""), "externals.", ""), ".", ""), 0, 63)
}

output "arn" {
  value = aws_sqs_queue.this.arn
}


variable "region" {}
variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_sqs_queue" "this" {
  name_prefix = local.name
}
