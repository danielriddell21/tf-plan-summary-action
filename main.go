package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type plan struct {
	ResourceChanges []resourceChange `json:"resource_changes"`
}

type resourceChange struct {
	Address string `json:"address"`
	Change  change `json:"change"`
}

type change struct {
	Actions []string `json:"actions"`
}

func actionLabel(actions []string) string {
	switch strings.Join(actions, ",") {
	case "create":
		return "➕ create"
	case "delete":
		return "🗑️ destroy"
	case "update":
		return "📝 update"
	case "create,delete", "delete,create":
		return "🔄 replace"
	default:
		return strings.Join(actions, " ")
	}
}

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

	var p plan
	if err := json.Unmarshal(data, &p); err != nil {
		fmt.Fprintf(os.Stderr, "failed to parse plan: %v\n", err)
		os.Exit(1)
	}

	var changes []resourceChange
	for _, r := range p.ResourceChanges {
		if len(r.Change.Actions) == 1 && r.Change.Actions[0] == "no-op" {
			continue
		}
		changes = append(changes, r)
	}

	counts := map[string]int{}
	for _, r := range changes {
		switch strings.Join(r.Change.Actions, ",") {
		case "create":
			counts["create"]++
		case "delete":
			counts["delete"]++
		case "update":
			counts["update"]++
		default:
			counts["replace"]++
		}
	}

	var sb strings.Builder
	sb.WriteString("## Terraform Plan\n\n")

	if len(changes) == 0 {
		sb.WriteString("✅ No changes — infrastructure is up to date.\n")
	} else {
		fmt.Fprintf(&sb,
			"**%d to add &nbsp;·&nbsp; %d to change &nbsp;·&nbsp; %d to destroy &nbsp;·&nbsp; %d to replace**\n\n",
			counts["create"], counts["update"], counts["delete"], counts["replace"],
		)
		sb.WriteString("| Action | Resource |\n")
		sb.WriteString("|--------|----------|\n")
		for _, r := range changes {
			fmt.Fprintf(&sb, "| %s | `%s` |\n", actionLabel(r.Change.Actions), r.Address)
		}

		if diff := unumDiff(planFile); diff != "" {
			sb.WriteString("\n<details><summary>Field-level diff</summary>\n\n```diff\n")
			sb.WriteString(diff)
			sb.WriteString("\n```\n\n</details>\n")
		}
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

func unumDiff(planFile string) string {
	out, err := exec.Command(
		"unum", "diff",
		"--format", "terraform",
		"--no-color",
		"--no-stat",
		"--quiet",
		planFile, planFile,
	).Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}
