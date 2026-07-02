package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/danielriddell21/unum/pkg/terraform"
)

func main() {
	planFile := "plan.json"
	if len(os.Args) > 1 {
		planFile = os.Args[1]
	}

	data, err := os.ReadFile(planFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "plan file not found: %s\n", planFile)
		os.Exit(1)
	}

	plan, err := terraform.Parse(data)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to parse plan: %v\n", err)
		os.Exit(1)
	}

	var sb strings.Builder
	sb.WriteString("## Terraform Plan\n\n")

	if !plan.HasChanges() {
		sb.WriteString("✅ No changes — infrastructure is up to date.\n")
	} else {
		sb.WriteString("Terraform will perform the following actions:\n\n")
		sb.WriteString("```diff\n")
		sb.WriteString(plan.RenderDiff(terraform.RenderOptions{
			MarkerFirst: true,
			BangUpdates: true,
		}))
		sb.WriteString("```\n\n")
		fmt.Fprintf(&sb, "Plan: %d to add, %d to change, %d to destroy, %d to replace.\n",
			plan.AddCount(), plan.ChangeCount(), plan.DestroyCount(), plan.ReplaceCount())
	}

	output := sb.String()
	if summaryFile := os.Getenv("GITHUB_STEP_SUMMARY"); summaryFile != "" {
		f, err := os.OpenFile(summaryFile, os.O_APPEND|os.O_WRONLY, 0644)
		if err == nil {
			defer f.Close()
			f.WriteString(output)
			return
		}
	}
	fmt.Print(output)
}
