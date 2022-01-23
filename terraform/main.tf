terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
  
  default_tags {
    tags = {
      Environment = "Dev"
      Origin      = "terraform"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}



resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Scope = "public"
  }
}


resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Scope = "private"
  }
}




resource "aws_security_group" "allow_db_inbound" {
  name        = "allow_db_inbound"
  description = "Allow inbound traffic to DB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}




resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



#resource "aws_iam_role" "ro_access_to_db" {
#  name = "ro_access_to_db"
#
#  assume_role_policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "VisualEditor0",
#            "Effect": "Allow",
#            "Action": [
#                "rds-db:connect"
#            ],
#            "Resource": [
#                "arn:aws:rds:us-east-2:913702812455:db:rocksend-db-dev",
#                "arn:aws:rds:us-east-2:913702812455:dbuser:rocksend-db-dev/rocksender"
#            ]
#        }
#    ]
#}
#EOF
#}


resource "aws_lambda_layer_version" "base_layer" {
  filename   = var.base_layer_pkg
  layer_name = "base_layer"
  source_code_hash = filebase64sha256(var.base_layer_pkg)

  compatible_runtimes = ["python3.9"]
}


resource "aws_lambda_function" "get_regions" {
  filename      = var.get_regions_pkg
  function_name = "get_regions"
  role          = "arn:aws:iam::913702812455:role/RockSender-role"
  handler = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256(var.get_regions_pkg)

  runtime = "python3.9"

  layers = [aws_lambda_layer_version.base_layer.arn]

  environment {
    variables = {
      foo = "bar"
    }
  }
  
  vpc_config {
    subnet_ids         = ["subnet-07b650d4e79cdee66"]
    security_group_ids = ["sg-069d26548be77dcf2"]
  }

  
#  lifecycle {
#  	ignore_changes = all
#  }
}



#
#
#   GATEWAY API
#
#




resource "aws_api_gateway_rest_api" "backend_api" {
  name        = "Backend API"
  description = "API for talking to backend lambdas"
}

resource "aws_api_gateway_resource" "get_regions" {
  rest_api_id = aws_api_gateway_rest_api.backend_api.id
  parent_id   = aws_api_gateway_rest_api.backend_api.root_resource_id
  path_part   = "get-regions"
}

resource "aws_api_gateway_method" "get_regions_method" {
  rest_api_id   = aws_api_gateway_rest_api.backend_api.id
  resource_id   = aws_api_gateway_resource.get_regions.id
  http_method   = "GET"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.backend_api.id
  resource_id             = aws_api_gateway_resource.get_regions.id
  http_method             = aws_api_gateway_method.get_regions_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_regions.invoke_arn
}



resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.backend_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.backend_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "beta" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.backend_api.id
  stage_name    = "beta"
}


# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_regions.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  #source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
  
}