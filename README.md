# Setting Up Jenkins, SonarQube, and Nexus on AWS using Terraform for CI/CD Pipeline Project

This repository provides Terraform configurations to set up Jenkins, SonarQube, and Nexus on AWS for creating a Continuous Integration/Continuous Deployment (CI/CD) pipeline environment. With Terraform, you can easily provision and manage the infrastructure needed to run these tools in the cloud.

## Prerequisites

Before you begin, make sure you have the following prerequisites:

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- An AWS account and AWS CLI configured with necessary credentials.

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/Kartikdudeja/aws-terraform-ci-cd-pipeline.git
   ```

2. Navigate to the project directory:

   ```bash
   cd aws-terraform-ci-cd-pipeline
   ```

3. Configure AWS credentials:

   Ensure that your AWS credentials are properly configured in your environment.

4. Modify `vars.tf`:

   Open the `vars.tf` file and update the variables with your specific information.

5. Initialize Terraform:

   ```bash
   terraform init
   ```

6. Preview the changes:

   ```bash
   terraform plan
   ```

7. Apply the configuration:

   ```bash
   terraform apply
   ```

   Confirm the deployment by typing `yes` when prompted.

8. Access the tools:

   - Jenkins: Access Jenkins by navigating to `http://jenkins-public-ip:8080` using the public IP assigned to the Jenkins EC2 instance.
   - SonarQube: Access SonarQube at `http://sonarqube-public-ip:9000` using the public IP assigned to the SonarQube EC2 instance.
   - Nexus: Access Nexus at `http://nexus-public-ip:8081` using the public IP assigned to the Nexus EC2 instance.

## Project Structure

The project directory is structured as follows:

```
aws-terraform-ci-cd-pipeline/
├── main.tf
├── vars.tf
├── provision/
│   ├── jenkins.sh
│   ├── sonar.sh
│   └── nexus.sh
└── README.md
```

- `main.tf`: The main Terraform configuration file defining the AWS resources to be created.
- `vars.tf`: Defines input variables for the Terraform configuration.
- `provision/`: Directory containing scripts for provisioning each tool.

## Customization

You can customize the `main.tf` file to include additional resources, security groups, or modify networking settings as needed. You can also customize the provisioning scripts in the `provision/` directory.

