# nuwe-zurich-cloud-hackathon-final BLOCK2

## Description

This project is my participation in the [Nuwe Zurich Cloud Hackathon](https://nuwe.io/dev/competitions/zurich-cloud-hackathon/final-phase-cloud-challenge)

These are the requirements of the hackathon Block 2:

Block 2 is about creating an IaC project infrastructure as professional as possible for a simple problem. The problem is being able to efficiently scale a WebApp for uploading images into an S3 AWS bucket. It is divided into three Parts:

1. Part 1: Design an infrastructure to scale efficiently the deployment of the WebApp as well as the storage of the images in the S3 AWS Bucket. The design should contain all the elements. This design should be written down in the Report ( Part 3 )
2. Part 2: Implement the explained above infrastructure using an IaC (Terraform or Cloud Formation) but pointing at localstack service instead of AWS. Every single decision should be explained, as well as the logic behind each of them. Every decision should at least answer the following questions:
   - Which part of the problem does it solve?
   - How efficient is it compared to other possible solutions?
   - How does it optimize costs?
3. Part 3: Create a Report designed for the stakeholders of the company. It should be as professional as possible. The report should contains at least the following items:
   - Diagram of the design done in Part 1.
   - Thoughts for each decision made in both Part 1 and Part 2.
   - Conclusion of the final results.


## Infrastructure

In this case there are a pdf report `part3_report.pdf` explanining all the infrastructure.

 
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


## Terraform files

The Terraform code is organised into the following files and directories:

- `main.tf`: This file contains the main Terraform configuration.
- `versions.tf`: This file defines the providers used.
- `outputs.tf`: This file defines the outputs of the root module.
- `variables.tf`: This file defines the variables used in the code, AWS region and AWS profile.
- `modules/`: Some modules I used. 
