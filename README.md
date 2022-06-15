This project contains custom modules

- 1. Creates multiple endpoints on API GW with local variable.
- 2. Creates dynamoDB tables with local variable.
- 3. Creates and pack lambda.

Create in AWS :

- 2 lambdas
- API GW with endpoints "created dynamically"
- DynamoDB "created dynamically "
- Creating log groups for lambdas

NEW ADDED

- logs visible from lambda
- new structure of files (more clear)
- added new endpoints
- uploading correctly now whole project
- partly Enabled logs from api gw

TO DO

- Finish adding SQS
- cleanup code with better names
- clear error from console 'Stage already exists' to don't display
- add aws_ssm_parameter
