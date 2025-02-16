terraform-aws-fargate-for-web
=============================

Terraform modules of AWS Fargate for web application

[![CI/CD](https://github.com/dceoy/terraform-aws-fargate-for-web/actions/workflows/ci.yml/badge.svg)](https://github.com/dceoy/terraform-aws-fargate-for-web/actions/workflows/ci.yml)

Installation
------------

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/terraform-aws-crud-http-api.git
    $ cd terraform-aws-crud-http-api
    ```

2.  Install [AWS CLI](https://aws.amazon.com/cli/) and set `~/.aws/config` and `~/.aws/credentials`.

3.  Install [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/).

4.  Build the Docker image.

    ```sh
    $ ./docker_buildx_bake.sh
    ```

5.  Initialize Terraform working directories.

    ```sh
    $ terragrunt run-all init --working-dir='envs/dev/' -upgrade -reconfigure
    ```

6.  Generates a speculative execution plan. (Optional)

    ```sh
    $ terragrunt run-all plan --working-dir='envs/dev/'
    ```

7.  Creates or updates infrastructure.

    ```sh
    $ terragrunt run-all apply --working-dir='envs/dev/' --non-interactive
    ```

Cleanup
-------

```sh
$ terragrunt run-all destroy --working-dir='envs/dev/' --non-interactive
```
