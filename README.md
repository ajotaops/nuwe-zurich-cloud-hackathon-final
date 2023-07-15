# nuwe-zurich-cloud-hackathon-final

## Description

This project is my participation in the [Nuwe Zurich Cloud Hackathon](https://nuwe.io/dev/competitions/zurich-cloud-hackathon/final-phase-cloud-challenge)

The objectives are divided into two main blocks.

1. BLOCK 1 is about creating a specific IaC project infrastructure as well as implement a local CI/CD on a git software. It is divided into two parts:

 - Part 1: Create and develop an infrastucture using an IaC, only Terraform or Cloud Formation. The infrastructure should create 2 EC2 instances in the same virtual cloud and subnet. Both instances would host services in the future. These services would be running in ports: 443 using TCP, 1337 using TCP and 3035 using TCP and UDP. Each instance should be accessed via SecureShell on the default port using a different key for each instance.

   - Decisions such as image, security group and scalability of the infrastructure, as well as the code, will be evaluated.
- Part 2: Create and automated a CI/CD pipeline using Jenkins and Gogs. Gogs is a described as a self-hosted Git service. The CI/CD pipeline should do the following:

  1. A IaC project should be hosted in the local Gogs hub in a git repository.
  2. When a change is pushed to the Gogs repository a new Jenkins Build is triggered.
  3. The Jenkins build checks for the validity of the IaC project.
  4. If IaC files are correct it checks if the infrastructure changes from the current.
  5. If there is any changes it deploy the changes. Block 2 is about creating an IaC project infrastructure as professional as possible for a simple problem. The problem is being able to efficiently scale a WebApp for uploading images into an S3 AWS bucket.

2. Block 2 is about creating an IaC project infrastructure as professional as possible for a simple problem. The problem is being able to efficiently scale a WebApp for uploading images into an S3 AWS bucket. It is divided into three Parts:

 - Part 1: Design an infrastructure to scale efficiently the deployment of the WebApp as well as the storage of the images in the S3 AWS Bucket. The design should contain all the elements. This design should be written down in the Report ( Part 3 )
 - Part 2: Implement the explained above infrastructure using an IaC (Terraform or Cloud Formation) but pointing at localstack service instead of AWS. Every single decision should be explained, as well as the logic behind each of them. Every decision should at least answer the following questions:
   - Which part of the problem does it solve?
   - How efficient is it compared to other possible solutions?
   - How does it optimize costs?
 - Part 3: Create a Report designed for the stakeholders of the company. It should be as professional as possible. The report should contains at least the following items:
   - Diagram of the design done in Part 1.
   - Thoughts for each decision made in both Part 1 and Part 2.
   - Conclusion of the final results.

Block 1 is inside `block1` folder and Block 2 is inside `block2` folder