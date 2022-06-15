### This project contains custom modules for :

* API Gateway - `Creates automatically endpoints depending on local vars`
* DynamoDB - `Creates automatically tables depending on local vars`
* Lambdas `Creates and pack project with lambda's`
* IAM - `Creates roles specifically for necessary resourcers`

### This terraform code create in AWS :

- 3 lambdas.
- API GW with endpoints, api key, usage plan and stage.
- 2 DynamoDB tables.
- Creating log groups for lambdas.
- Roles for lambdas and API GW

#### TO DO

- Finish adding SQS
- cleanup code with better names
- clear error from console 'Stage already exists' to don't display
- add aws_ssm_parameter `type of local env values for js files`

##### IDEA
- Maybe create api with other resources -> https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway
