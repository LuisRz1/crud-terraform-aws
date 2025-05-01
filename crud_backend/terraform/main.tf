provider "aws" {
  region = "us-west-2"  # Cambia a la región que prefieras
}

# 1. IAM Role para Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect    = "Allow",
    }]
  })
}

# 2. Base de datos RDS (MySQL)
resource "aws_db_instance" "product_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  name                 = "products_db"
  username             = "admin"
  password             = "your-password"  # Cambia la contraseña
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = false
  backup_retention_period = 7  # Días de retención de backup

  tags = {
    Name = "ProductDatabase"
  }

  wait_for_available = true
}

# 3. API Gateway
resource "aws_api_gateway_rest_api" "product_api" {
  name        = "Product API"
  description = "API for CRUD operations on products"
}

# 4. Crear recursos para API Gateway
resource "aws_api_gateway_resource" "products" {
  rest_api_id = aws_api_gateway_rest_api.product_api.id
  parent_id   = aws_api_gateway_rest_api.product_api.root_resource_id
  path_part   = "products"
}

# 5. Métodos para las funciones Lambda (POST, GET, PUT, DELETE)
resource "aws_api_gateway_method" "create_product_method" {
  rest_api_id   = aws_api_gateway_rest_api.product_api.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "POST"
  authorization = "NONE"
  integration {
    type                      = "AWS_PROXY"
    integration_http_method    = "POST"
    uri                       = aws_lambda_function.create_product.invoke_arn
  }
}

resource "aws_api_gateway_method" "get_product_method" {
  rest_api_id   = aws_api_gateway_rest_api.product_api.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "GET"
  authorization = "NONE"
  integration {
    type                      = "AWS_PROXY"
    integration_http_method    = "GET"
    uri                       = aws_lambda_function.get_product.invoke_arn
  }
}

resource "aws_api_gateway_method" "update_product_method" {
  rest_api_id   = aws_api_gateway_rest_api.product_api.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "PUT"
  authorization = "NONE"
  integration {
    type                      = "AWS_PROXY"
    integration_http_method    = "PUT"
    uri                       = aws_lambda_function.update_product.invoke_arn
  }
}

resource "aws_api_gateway_method" "delete_product_method" {
  rest_api_id   = aws_api_gateway_rest_api.product_api.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "DELETE"
  authorization = "NONE"
  integration {
    type                      = "AWS_PROXY"
    integration_http_method    = "DELETE"
    uri                       = aws_lambda_function.delete_product.invoke_arn
  }
}

# 6. Desplegar API Gateway
resource "aws_api_gateway_deployment" "product_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.product_api.id
  stage_name  = "prod"
}

# 7. Funciones Lambda
resource "aws_lambda_function" "create_product" {
  function_name = "create_product"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "create_product.handler.lambda_handler"
  filename      = "create_product.zip"  # Path al archivo ZIP de tu Lambda
  environment {
    variables = {
      DB_HOST     = aws_db_instance.product_db.endpoint  # Se obtiene automáticamente
      DB_USER     = "admin"  # Usuario de la base de datos
      DB_PASSWORD = "your-password"  # Contraseña de la base de datos
      DB_NAME     = "products_db"  # Nombre de la base de datos
    }
  }
}

resource "aws_lambda_function" "get_product" {
  function_name = "get_product"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "get_product.handler.lambda_handler"
  filename      = "get_product.zip"  # Path al archivo ZIP de tu Lambda
  environment {
    variables = {
      DB_HOST     = aws_db_instance.product_db.endpoint
      DB_USER     = "admin"
      DB_PASSWORD = "your-password"
      DB_NAME     = "products_db"
    }
  }
}

resource "aws_lambda_function" "update_product" {
  function_name = "update_product"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "update_product.handler.lambda_handler"
  filename      = "update_product.zip"  # Path al archivo ZIP de tu Lambda
  environment {
    variables = {
      DB_HOST     = aws_db_instance.product_db.endpoint
      DB_USER     = "admin"
      DB_PASSWORD = "your-password"
      DB_NAME     = "products_db"
    }
  }
}

resource "aws_lambda_function" "delete_product" {
  function_name = "delete_product"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "delete_product.handler.lambda_handler"
  filename      = "delete_product.zip"  # Path al archivo ZIP de tu Lambda
  environment {
    variables = {
      DB_HOST     = aws_db_instance.product_db.endpoint
      DB_USER     = "admin"
      DB_PASSWORD = "your-password"
      DB_NAME     = "products_db"
    }
  }
}

# 8. Permisos para que API Gateway invoque las funciones Lambda
resource "aws_lambda_permission" "allow_api_gateway_create" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_product.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_api_gateway_get" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_product.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_api_gateway_update" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_product.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_api_gateway_delete" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_product.function_name
  principal     = "apigateway.amazonaws.com"
}
