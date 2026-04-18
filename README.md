# tf-plan-summary-action

[![CI](https://github.com/danielriddell21/tf-plan-summary-action/actions/workflows/ci.yml/badge.svg)](https://github.com/danielriddell21/tf-plan-summary-action/actions/workflows/ci.yml)
[![Go 1.26](https://img.shields.io/badge/go-1.26-00ADD8?logo=go)](https://go.dev)

Parses `terraform show -json` output and writes a human-readable summary to the GitHub Actions job summary — a diff table plus a collapsible field-level diff powered by [unum](https://github.com/danielriddell21/unum).

## Example output

**Summary table** (always shown):

**2 to add &nbsp;·&nbsp; 1 to change &nbsp;·&nbsp; 0 to destroy &nbsp;·&nbsp; 0 to replace**

| Action | Resource |
|--------|----------|
| ➕ create | `aws_instance.web` |
| ➕ create | `aws_security_group.web` |
| 📝 update | `aws_s3_bucket.assets` |

**Field-level diff** (collapsed beneath the table):

<details><summary>Field-level diff</summary>

```diff
+ .aws_instance.web                         
+ .aws_security_group.web                   
- .aws_instance.legacy                      
! .aws_s3_bucket.assets.versioning.enabled  false → true
```

</details>

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
