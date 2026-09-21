# Project guidance for future Codex sessions

This is a college MSE project: **Automated Multi-Environment Cloud Infrastructure Deployment Using Terraform and AWS**.

## Non-negotiable rubric requirements

- Keep one shared Terraform configuration (`main.tf`); do not create separate dev/prod main files.
- The intended non-default Terraform workspaces are exactly `dev` and `prod`; they isolate state. Do not use an automatic workspace-creation mechanism.
- Keep `terraform.tfvars.dev` and `terraform.tfvars.prod`, with distinct environment, instance type, and instance count values.
- Dev must remain `t3.micro` with one instance; prod must remain `t3.small` with three instances.
- Keep at least these variables: project_name, environment, region, instance_type, instance_count, and allowed_ssh_cidr.
- Discover VPC, subnets, availability zones, and the Amazon Linux AMI through AWS data sources. Never hardcode VPC, subnet, or AMI IDs.
- Every taggable resource must have useful tags including `Project`, `Environment`, and `ManagedBy = "Terraform"`.
- Keep the web security group limited to HTTP (80) and configurable SSH (22). Do not add unnecessary inbound ports.
- Never add AWS credentials, access keys, private keys, passwords, state files, or unapproved secrets to the repository.
- Do not run `terraform apply` or `terraform destroy` unless the user explicitly asks. Plans should be inspected first.

## Quality bar

After Terraform edits, run `terraform fmt -check` and `terraform validate` where the local Terraform installation/provider initialization permits it. Update the beginner-friendly README when project behavior or commands change.
