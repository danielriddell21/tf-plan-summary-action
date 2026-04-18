import json
import os
import sys

ICONS = {
    ("create",):           "➕ create",
    ("delete",):           "🗑️ destroy",
    ("update",):           "📝 update",
    ("create", "delete"):  "🔄 replace",
    ("delete", "create"):  "🔄 replace",
}

def action_label(actions: list[str]) -> str:
    return ICONS.get(tuple(actions), " ".join(actions))

def main() -> None:
    plan_file = sys.argv[1] if len(sys.argv) > 1 else "plan.json"
    summary_file = os.environ.get("GITHUB_STEP_SUMMARY")

    if not os.path.exists(plan_file):
        print(f"Plan file not found: {plan_file}", file=sys.stderr)
        sys.exit(1)

    with open(plan_file) as f:
        plan = json.load(f)

    changes = [
        r for r in plan.get("resource_changes", [])
        if r["change"]["actions"] != ["no-op"]
    ]

    counts = {"create": 0, "delete": 0, "update": 0, "replace": 0}
    for r in changes:
        actions = r["change"]["actions"]
        if actions == ["create"]:
            counts["create"] += 1
        elif actions == ["delete"]:
            counts["delete"] += 1
        elif actions == ["update"]:
            counts["update"] += 1
        elif set(actions) == {"create", "delete"}:
            counts["replace"] += 1

    lines = ["## Terraform Plan", ""]

    if not changes:
        lines.append("✅ No changes — infrastructure is up to date.")
    else:
        summary = (
            f"**{counts['create']} to add &nbsp;·&nbsp; "
            f"{counts['update']} to change &nbsp;·&nbsp; "
            f"{counts['delete']} to destroy &nbsp;·&nbsp; "
            f"{counts['replace']} to replace**"
        )
        lines += [
            summary,
            "",
            "| Action | Resource |",
            "|--------|----------|",
        ]
        for r in changes:
            label = action_label(r["change"]["actions"])
            lines.append(f"| {label} | `{r['address']}` |")

    output = "\n".join(lines) + "\n"

    if summary_file:
        with open(summary_file, "a") as f:
            f.write(output)
    else:
        print(output)

if __name__ == "__main__":
    main()
