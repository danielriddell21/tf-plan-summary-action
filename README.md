# tf-plan-summary-action

Parses `terraform show -json` output and writes a human-readable diff table to the GitHub Actions job summary.

## Example output

```
## Terraform Plan

**2 to add · 1 to change · 0 to destroy · 0 to replace**

| Action     | Resource                          |
|------------|-----------------------------------|
| ➕ create  | `aws_instance.web`                |
| ➕ create  | `aws_security_group.web`          |
| 📝 update  | `aws_s3_bucket.assets`            |
```

## Usage

```yaml
- name: Generate plan JSON
  run: terraform show -json tfplan > plan.json

- name: Terraform Plan Summary
  uses: danielriddell21/tf-plan-summary-action@v1
  with:
    plan-file: plan.json
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `plan-file` | Path to the `terraform show -json` output file, relative to the workspace root. | No | `plan.json` |

## Example workflow

```yaml
jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "~1.6"

      - name: init
        run: terraform init

      - name: plan
        run: |
          terraform plan -no-color -input=false -out=tfplan
          terraform show -json tfplan > plan.json

      - name: Terraform Plan Summary
        uses: danielriddell21/tf-plan-summary-action@v1
        with:
          plan-file: plan.json
```
