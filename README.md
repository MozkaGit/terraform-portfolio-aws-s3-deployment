# Deploying a Static Website with Terraform<br>[![.github/workflows/build.yaml](https://github.com/MozkaGit/terraform-s3-static-website/actions/workflows/build.yaml/badge.svg)](https://github.com/MozkaGit/terraform-s3-static-website/actions/workflows/build.yaml)

This project aims to deploy a static website (portfolio) on an Amazon S3 bucket using Terraform. The deployment process will be automated using the provided Terraform scripts.

![Architecture diagram](https://github.com/MozkaGit/terraform-s3-static-website/assets/43102748/4f142545-edef-4e99-a466-a7e6cfe61530)

## Prerequisites

Before getting started, ensure that you have the following tools installed on your machine:

- An AWS account with access keys and permissions to deploy resources.
- Terraform installed locally on your development machine.
- AWS CLI in order to configure credentials.

## AWS Configuration

Make sure you have correctly configured AWS credentials on your machine.

```
aws configure
```

## Website Deployment

To deploy the static website, follow these steps:

1. Clone this repository to your local machine.

2. Navigate to the project directory.

3. Run the command `terraform init` to initialize Terraform and download the required providers.

4. Run the command `terraform apply` to create the resources on AWS.

5. The deployment process may take a few moments. Once completed, you will see the URL (endpoint) of the deployed static website.

```
Outputs:

website_endpoint = "http://web-server-flowing-owl.s3-website-us-east-1.amazonaws.com"
```

## Cleanup

To avoid unnecessary charges, make sure to run `terraform destroy` in order to destroy the created resources after finishing your tests.

## Acknowledgements

The [website template](https://startbootstrap.com/theme/freelancer) used in this project is the freelancer theme created by [Start Bootstrap](https://startbootstrap.com/).
