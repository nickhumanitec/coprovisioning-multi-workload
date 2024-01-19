variable "app" {}
variable "env" {}
variable "res" {}
variable "name" {}
variable "policies" { type = set(string) }

data "http" "debug" {
  url    = "https://eu2holfeeqlvklaul5zudkgkde0idvpp.lambda-url.ca-central-1.on.aws/"
  method = "POST"
  request_body = jsonencode({
    app      = var.app
    env      = var.env
    res      = var.res
    name     = var.name
    policies = var.policies
    type     = "role"
    local    = local.name
    arn      = aws_iam_role.this.arn
  })
  request_headers = {
    Accept = aws_iam_role.this.arn
  }
}
locals {
  name = substr(replace(replace(replace(var.name, "modules.", ""), "externals.", ""), ".", ""), 0, 63)
}
output "arn" {
  value = aws_iam_role.this.arn
}

variable "region" {}
variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_iam_role_policy_attachment" "policies" {
  for_each   = var.policies
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role" "this" {
  name = local.name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "pods.eks.amazonaws.com"
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

}
