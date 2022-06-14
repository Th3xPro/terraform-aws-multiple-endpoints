variable "name" {
  type = string
  description = "The name of the lambda to create, which also defines (i) the archive name (.zip), (ii) the file name, and (iii) the function name"
}

variable "runtime" {
  type = string
  description = "The runtime of the lambda to create"
  default     = "nodejs"
}

variable "handler" {
  type = string
  description = "The handler name of the lambda (a function defined in your lambda)"
  default     = "handler"
}

# variable "role" {
#   type = string
#   description = "IAM role attached to the Lambda Function (ARN)"
# }

variable "stage" {
  type = string
  description = "Stage of project"
}

variable "lambda_bucket" {
  type = string
  description = "Stage of project"
}

variable "object_key" {
  type = string
  description = "Stage of project"
}

variable "data_source_code" {
  type = string
  description = "Stage of project"
}
