# terraform-tk-aws
This project is intended to serve as a test kitchen of Terraform code for AWS. There may be some recipes that come from
this, but there may be some things in here that you wouldn't tell others you eat. That's mostly because this is serving
as a learning exercise for me. My intent is to use "real world" requirements and challenges (such as multiple
environments, users and developers in different geographic areas, etc.) to drive my learning.


## Things To Know
I am attempting to keep any resources that this creates in the free tier for AWS. However, I would highly advise
performing a [complete resource shutdown](#shutting-down-resources) at the end of every time you work with these
scripts. I cannot guarantee that you will not incur costs while using this project.

## Getting Started
### Prerequisites
* The [Terraform CLI (1.10.0+)](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed.
* The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed.
* [AWS account](https://aws.amazon.com/free) and [associated credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html) that allow you to create resources.

Once you have the necessary credentials, you can use the `aws configure` [command](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html)
to set your access key ID and secret values for use by the AWS CLI and Terraform. Alternatively, you can set the
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables to the same end.

### Bootstrapping Your Environment
The main (root) Terraform module *can* be used as is with a local Terraform state file. However, it is not advisable for
a number of reasons. The first and most important of which is that the bootstrap module will create a budget for you to
ensure that you are notified if you incur any costs in AWS. It also creates a versioned S3 bucket to hold your Terraform
state, helping to ensure that you can recover past versions of your state file if needed. Once the S3 bucket has been
created, the bootstrap module generates a `backend.tf` that will be picked and used automatically when you initialize
the main module. Typically, a backend configuration file would be held in version control. However, in this case, I have
prioritized making getting started as simple as possible, and providing a bootstrap module that generates the necessary
backend configuration seemed appropriate.

The bootstrap module can be found in the `bootstrap` subdirectory of the project root. Start by opening a shell in that
directory. All bootstrap module commands should be run from this shell.

#### Bootstrap Variables
The following variable(s) are utilized by the bootstrap module:
* ```region``` - **string** - The region into which bootstrap resources will be deployed (when applicable), defaults to "us-east-2"
* ```budget_notification_recipients``` - **set(string)** - The set of email addresses that should be notified if the budget is exceeded, no default value

You will be prompted for value(s) for any variable(s) for which you have not provided a value already by
[passing a value via the CLI](https://developer.hashicorp.com/terraform/language/values/variables#variables-on-the-command-line),
by using a [variable definition file](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files),
or [setting the appropriate environment variable](https://developer.hashicorp.com/terraform/language/values/variables#environment-variables).
A [sample variable definition](https://github.com/mkimberlin/terraform-tk-aws/blob/main/bootstrap/terraform.tfvars.sample)
file has been provided in the bootstrap module directory. To utilize the sample file, edit its values appropriately and
save it under the name `terraform.tfvars` in the same directory. Doing so will cause the file to be picked up
automatically. Otherwise, you may be prompted for values and your resources may deploy to a region
other than the one you desire. I am leaving this step manual (copying and editing the bootstrap variables), because
failing to edit them appropriately will result in not receiving any budget alerts that are generated, meaning you may
not be aware of money being spent before it is too late. Hopefully this step is a minor inconvenience in service of
helping you avoid that fate.

#### Initialize The Bootstrap Module
Once you have set the bootstrap variables appropriately, you can initialize the bootstrap module using `terraform init`
command from the `bootstrap` directory. You should see messages acknowledging the successful initialization of Terraform.

#### Review The Bootstrap Resources
This step is optional, but gives you the opportunity to review the resources to be created as a part of the bootstrap
process. To do this, run `terraform plan` from the `bootstrap` directory. If you have not properly set your [bootstrap variables](#bootstrap-variables)
you will be prompted for them at this point. Once set, Terraform will display its deployment plan. Review this to your
satisfaction and proceed to the next step.

#### Deploy The Bootstrap Resources
Now simply run `terraform apply` (again from the `bootstrap` directory) and confirm the deployment when prompted. Once
this completes, the `backend.tf` file will be generated in the project root directory, and your main module will be ready to use!

### Provisioning Default Resources

#### Initialize Main Module
Once you have [bootstrapped your environment](#bootstrapping-your-environment), you can initialize the main module by
running the `terraform init` command from the project root directory. You should see messages acknowledging the
successful initialization of Terraform.

#### Review Main Module Resources
Once again, this step is optional, but it gives you the opportunity to review the resources to be created. To do this,
run `terraform plan` from the project root directory. Terraform will display its deployment plan. Review this to your
satisfaction and proceed to the next step.

#### Deploy Main Module Resources
Now simply run `terraform apply` (again from the project root directory) and confirm the deployment when prompted. Once
this completes, the project's resources will be available for use on AWS.

## Shutting Down Resources
In order to fully destroy all resources created by these scripts, you will need to first run `terraform destroy` from
the project root directory and confirm the destruction of the resources when prompted. Once you've done this, it is also
advisable to remove your bootstrap resources as well if you are done working with these scripts. You can do this by
running `terraform destroy` from the `bootstrap/` subdirectory. Assuming both of these commands complete without error,
all the resources created by these scripts should have been removed.

## Project Structure
The project root contains the main Terraform module. This module drives the creation of all other resources in a
configurable fashion.
* `${PROJECT_ROOT}`
    * `terraform.tf` - Terraform configuration block (including required providers)
    * `main.tf` - Main module (loads the global module, as well as any other configured environments)
    * `providers.tf` - Configures the [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs), and any other Providers that might be added later
    * `variables.tf` - Defines the [input variables](https://developer.hashicorp.com/terraform/language/values/variables) accepted by the module, including their defaults
    * `bootstrap/` - A stand alone Terraform module that sets up a $0.01 budget alarm, prepares an S3 bucket to hold shared Terraform State, and generates a [S3 backend configuration](https://developer.hashicorp.com/terraform/language/backend/s3) for the root module
    * `environments/` - A directory containing the [environment definitions](#environment-definitions) for this project
        * `global/` - Resources used by all environments
        * `development/` - A set of environments meant to mimic a development deployment servicing developers in the Asia and the US.
        * `production/` - A set of environments meant to mimic a production deployment servicing developers in Asia, Europe, and the US.
    * `modules/` - A directory containing the [reusable modules](#reusable-modules) for this project. These will generally be logical groupings of related resources.

## Environment Definitions
There are multiple environments that can be configured for deployment. They are broken down into modules that are
intended to represent development and production environments supporting different geographic areas. These can be found
in the `environments` subdirectory from the project root. Whether these environments are deployed is determined
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

## Reusable Modules
The `modules` directory contains this project's reusable modules. These will generally be logical groupings of related
resources. That might be a subnet definition, a grouping of application resources, or something similar. I'll describe
these below as they are added.

### `file-upload` Module
This module contains an application component meant to support upload of some sort of file to an [S3 Bucket](https://docs.aws.amazon.com/s3/)
by a specific group of users within the organization. When a user uploads a new file to the bucket, a [Lambda Function](https://docs.aws.amazon.com/lambda/)
is triggered that publishes some file information to an [SQS message](https://docs.aws.amazon.com/sqs/) queue.
