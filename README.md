# Rearc Data Quest Exploration

This is an exploration of [https://github.com/rearc-data/quest](https://github.com/rearc-data/quest).

![Data Quest IaC Diagram](diagram.png)

## Quest Submission

### Step 1

- Link to data in S3: [pr.class](https://data-quest-bucket.s3.amazonaws.com/pr.class), [pr.contacts](https://data-quest-bucket.s3.amazonaws.com/pr.contacts), [pr.data.0.Current](https://data-quest-bucket.s3.amazonaws.com/pr.data.0.Current), [pr.data.1.AllData](https://data-quest-bucket.s3.amazonaws.com/pr.data.1.AllData), [pr.duration](https://data-quest-bucket.s3.amazonaws.com/pr.duration), [pr.footnote](https://data-quest-bucket.s3.amazonaws.com/pr.footnote), [pr.measure](https://data-quest-bucket.s3.amazonaws.com/pr.measure), [pr.period](https://data-quest-bucket.s3.amazonaws.com/pr.period), [pr.seasonal](https://data-quest-bucket.s3.amazonaws.com/pr.seasonal), [pr.sector](https://data-quest-bucket.s3.amazonaws.com/pr.sector), [pr.series](https://data-quest-bucket.s3.amazonaws.com/pr.series), [pr.txt](https://data-quest-bucket.s3.amazonaws.com/pr.txt), [population.json](https://data-quest-bucket.s3.amazonaws.com/population.json).
- Source code: `/part1/sync_data.py`.

### Step 2

- Source code: `/part2/fetch_data.py`.

### Step 3

- Source code in .ipynb file format and results: `/part3/data_analytics.ipynb`.

### Step 4

- Source code of data pipeline infrastructure: `/part4/terraform_IaC`.

## Running the AWS Terraform IaC

1. Download the files from `/part4/terraform_IaC` into a local directory.
2. [Download and install Terraform](https://www.terraform.io/downloads), adding it to PATH.
3. Run `terraform init` within your local IaC directory using a terminal.
4. Set your own `access_key` and `secret_key` in a `terraform.tfvars` file within your local IaC directory. Any other variables from `variables.tf` can be customized in `terraform.tfvars` too. You can set a variable in `terraform.tfvars` using a line-by-line format like `access_key = "AW3JLRW29FJE4WP9A"`.
5. Run `terraform plan` to view the possible changes, and `terraform apply -auto-approve` to automatically approve these changes and run the IaC.

Note that some of these steps take some time for setup. The functions don't run automatically until the first daily event triggers, but you can test the functions on the AWS Management Console.

When removing the infrastructure, making sure to empty the S3 bucket first otherwise it won't be destroyed.
