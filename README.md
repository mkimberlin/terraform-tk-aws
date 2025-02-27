# terraform-tk-aws
This project is intended to serve as a test kitchen of Terraform code for AWS. There may be some recipes that come from
this, but there may be some things in here that you wouldn't tell others you eat. That's mostly because this is serving
as a learning exercise for me. My intent is to use "real world" requirements and challenges (such as multiple
environments, users and developers in different geographic areas, etc.) to drive my learning.

## Prerequisites
* The [Terraform CLI (1.10.0+)](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed.
* The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed.
* [AWS account](https://aws.amazon.com/free) and [associated credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html) that allow you to create resources.

Once you have the necessary credentials, you can use the `aws configure` [command](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html)
to set your access key ID and secret values for use by the AWS CLI and Terraform. Alternatively, you can set the
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables to the same end.

## Things To Know
I am attempting to keep any resources that this creates in the free tier for AWS. However, I would highly advise running
```terraform destroy``` at the end of every time you work with these test scripts. I cannot guarantee that you will not
incur costs using this project.

## Required Variables
The following variable(s) do not have defaults and must be defined by the user:
* ```budget_notification_recipients``` - **set(string)** - The set of email addresses that should be notified if the budget is exceeded

You will be prompted for value(s) for these variables if not provided by
[passing a value via the CLI](https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line),
by using a [variable definition file](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files),
or [setting the appropriate environment variable](https://developer.hashicorp.com/terraform/language/values/variables#environment-variables).

## Project Structure
The project root contains the main Terraform module. This module drives the creation of all other resources in a
configurable fashion. 
* `${PROJECT_ROOT}`
  * `terraform.tf` - Terraform configuration block (including required providers)
  * `main.tf` - Main module (loads the global module, as well as any other configured environments)
  * `providers.tf` - Configures the [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs), and any other Providers that might be added later
  * `variables.tf` - Defines the [input variables](https://developer.hashicorp.com/terraform/language/values/variables) accepted by the module, including their defaults
  * `environments/` - A directory containing the [environment definitions](#environment-definitions) for this project
    * `global/` - Resources used by all environments
    * `development/` - A set of environments meant to mimic a development deployment servicing developers in the Asia and the US.
    * `production/` - A set of environments meant to mimic a production deployment servicing developers in Asia, Europe, and the US.
  * `modules/` - A directory containing the [reusable modules](#reusable-modules) for this project. These will generally be logical groupings of related resources.

### Environment Definitions
There are multiple environments that can be configured for deployment. They are broken down into modules that are
intended to represent development and production environments supporting different geographic areas. These can be found
in the `environments` subdirectory from the project root. Whether or not these environments are deployed is determined
by the value of the `environments` variable (`["development/us"]` by default).

The `environments` directory contains the following modules:
 * `global` - contains global resources such as IAM resources, budgets, etc. that will always be deployed
 * `development`
   * `asia` - referenced as `development/asia`
   * `us` - referenced as `development/us` and the only environment deployed to by default other than `global`
 * `production`
   * `asia` - referenced as `production/asia`
   * `europe` - referenced as `production/europe`
   * `us` - referenced as `production/us`

So, if you want to deploy both the development and production environments in the US geographic area, you set the value
of the `environments` input variable to `["development/us","production/us"]`. This can be done via the same mechanisms
described in the [Required Variables](#required-variables) section.

### Reusable Modules
The `modules` directory contains this project's reusable modules. These will generally be logical groupings of related
resources. That might be a subnet definition, a grouping of application resources, or something similar. I'll describe
these below as they are added.

#### `file-upload` Module
This module contains an application component meant to support upload of some sort of file to an [S3 Bucket](https://docs.aws.amazon.com/s3/)
by a specific group of users within the organization. When a user uploads a new file to the bucket, a [Lambda Function](https://docs.aws.amazon.com/lambda/)
is triggered that publishes some file information to an [SQS message](https://docs.aws.amazon.com/sqs/) queue.
