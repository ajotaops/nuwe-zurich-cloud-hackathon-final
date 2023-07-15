# nuwe-zurich-cloud-hackathon-final BLOCK1

## Description

This project is my participation in the [Nuwe Zurich Cloud Hackathon](https://nuwe.io/dev/competitions/zurich-cloud-hackathon/final-phase-cloud-challenge)

These are the requirements of the hackathon Block 1:

BLOCK 1 is about creating a specific IaC project infrastructure as well as implement a local CI/CD on a git software. It is divided into two parts:

1. Part 1: Create and develop an infrastucture using an IaC, only Terraform or Cloud Formation. The infrastructure should create 2 EC2 instances in the same virtual cloud and subnet. Both instances would host services in the future. These services would be running in ports: 443 using TCP, 1337 using TCP and 3035 using TCP and UDP. Each instance should be accessed via SecureShell on the default port using a different key for each instance.

   - Decisions such as image, security group and scalability of the infrastructure, as well as the code, will be evaluated.
2. Part 2: Create and automated a CI/CD pipeline using Jenkins and Gogs. Gogs is a described as a self-hosted Git service. The CI/CD pipeline should do the following:

   - A IaC project should be hosted in the local Gogs hub in a git repository.
   - When a change is pushed to the Gogs repository a new Jenkins Build is triggered.
   - The Jenkins build checks for the validity of the IaC project.
If IaC files are correct it checks if the infrastructure changes from the current.
If there is any changes it deploy the changes.


## Infrastructure

The infrastructure is defined using modules, which are reusable components that encapsulate specific functionalities. The configuration starts by specifying the AWS provider and setting up variables such as the region, AWS profile, VPC name, CIDR block, availability zones, EC2 names, and tags.

The VPC module is then used to create a VPC with the specified name and CIDR block. It uses the availability zones provided and creates public subnets in those zones. The VPC is configured to allow instances launched within it to have a public IP address.

The EC2 module is used to create EC2 instances. It first creates a security group allowing incoming traffic on ports 22 (SSH), 443 (HTTPS), 1337, and 3035 (both TCP and UDP) from any IP address. Then, it generates a key pair for each EC2 instance using the names provided. Finally, it creates EC2 instances of type "t2.micro" in the public subnets of the VPC. The instances are associated with the security group. Tags are added to the instances for identification purposes.

The code is designed to be scalable by using the "for_each" loop in the modules. By specifying additional EC2 names in the "ec2_names" variable, more EC2 instances can be created simply by adding them to the variable. This allows for easy scaling of the infrastructure.

Overall, this configuration sets up a VPC with public subnets, a security group, and EC2 instances on AWS. The use of modules and a scalable code structure enables easy management and expansion of the infrastructure.
 
## Requirements

Before using this code, make sure you have the following configured:

- [Terraform](https://www.terraform.io/downloads.html) installed.
- Configured AWS profile or you can [configure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) your preferred method.

## Usage

Follow these steps to use the Terraform code:

1. Clone this repository on your local machine.
2. Copy the `terraform.tfvars.dist` file to `terraform.tfvars` and adjust the configuration values to suit your needs.
3. Run the following command in the root directory of the project:

   ```shell
   terraform init
   ```

   This will initialise the Terraform backend and download the necessary plugins.

4. Review the resources that will be created with the following command:

   ```shell
   terraform plan
   ```

   This will show you a description of the resources that will be created. On total 11 resources.

5. Finally, run the following command to create the resources in AWS:

   ```shell
   terraform apply
   ```

   Confirm the execution by typing "yes" when prompted.

6. To see the private key generated you need to run the following command:
   ```shell
   terraform output -json
   ```


## Terraform files

The Terraform code is organised into the following files and directories:

- `main.tf`: This file contains the main Terraform configuration.
- `versions.tf`: This file defines the providers used.
- `outputs.tf`: This file defines the outputs of the root module, we export privates keys from machine in sensitive mode.
- `variables.tf`: This file defines the variables used in the code, AWS region and AWS profile.
