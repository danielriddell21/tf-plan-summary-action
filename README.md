# tf-plan-summary-action

[![CI](https://github.com/danielriddell21/tf-plan-summary-action/actions/workflows/ci.yml/badge.svg)](https://github.com/danielriddell21/tf-plan-summary-action/actions/workflows/ci.yml)
[![Go 1.26](https://img.shields.io/badge/go-1.26-00ADD8?logo=go)](https://go.dev)

Parses `terraform show -json` output and writes a human-readable summary to the GitHub Actions job summary — a diff table plus a collapsible, `terraform plan`-style field-level diff. The plan parsing and rendering are provided by the importable [`unum/pkg/terraform`](https://github.com/danielriddell21/unum/tree/trunk/pkg/terraform) package, so the action is a single self-contained Go build with no runtime CLI dependency.

## Example output

The `## Terraform Plan` heading, the `Terraform will perform…` preamble and the `Plan:` summary line sit outside the code block. Inside the fenced ```diff``` block, change markers are in column 0 so GitHub colours the lines: `+` created (green), `-` destroyed (red) and `!` updated-in-place (amber):

---

## Terraform Plan

Terraform will perform the following actions:

```diff
    # aws_instance.web will be created
+   resource "aws_instance" "web" {
+     ami           = "ami-123"
+     arn           = (known after apply)
+     instance_type = "t3.micro"
+   }

    # aws_s3_bucket.assets will be updated in-place
!   resource "aws_s3_bucket" "assets" {
!     versioning {
!       enabled = false -> true
!     }
      # (1 unchanged attribute hidden)
!   }

    # aws_instance.legacy will be destroyed
-   resource "aws_instance" "legacy" {
-     ami           = "ami-old" -> null
-     instance_type = "t2.micro" -> null
-   }
```

Plan: 2 to add, 1 to change, 1 to destroy, 0 to replace.

---

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
