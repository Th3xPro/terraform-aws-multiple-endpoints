variable "aws_region" {
  description = "AWS region"
  default     = "eu-central-1"
}
variable "stage" {
  description = "AWS API Stage"
  default     = "dev"
}

variable "settler_endpoints" {
  description = "A map of settlers endpoints"
  
  type = list(object({
               path = string,
               method = string,
               additional = bool,
               parameter = string
            }))
            
  default = [{ 
        path = "settlers",
        method = "GET"
        additional = false
        parameter = ""
   },{ 
        path = "settlers",
        method = "GET"
        additional = true
        parameter = "{cityId}"
   },{ 
        path = "settler",
        method = "GET"
        additional = true
        parameter = "{ID}"
   },{  
        path = "settler",
        method = "PUT"
        additional = false
        parameter = ""
   }]
  # settler:
  #   handler: src/handlers/settler.handler
  #   events:
  #     - http:
  #         path: settlers
  #         method: GET
  #         cors: true
  #         private: true
  #     - http:
  #         path: settlers/{cityId}
  #         method: GET
  #         cors: true
  #         private: true
  #     - http:
  #         path: settler/{ID}
  #         method: GET
  #         cors: true
  #         private: true
  #     - http:
  #         path: settler
  #         method: PUT
  #         cors: true
  #         private: true
}

variable "test" {
  type = list(object({
               path = string,
               method = string,
               additional = bool,
               parameter = string
            }))
            
  default = [{ 
        path = "settlers",
        method = "GET"
        additional = false
        parameter = ""
   },{ 
        path = "settlers",
        method = "GET"
        additional = true
        parameter = "{cityId}"
   },{ 
        path = "settler",
        method = "GET"
        additional = true
        parameter = "{ID}"
   },{  
        path = "settler",
        method = "PUT"
        additional = false
        parameter = ""
   }]
}