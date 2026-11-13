#!/usr/bin/env python3

import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[2]
SKILLS = ROOT / "skills"

NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
FIELD_PATTERN = re.compile(r"^([A-Za-z][A-Za-z0-9_-]*):\s*(.*)$")
LINK_PATTERN = re.compile(r"!?\[[^\]\n]*\]\(([^)\n]+)\)")
REFERENCE_PATTERN = re.compile(r"^\s{0,3}\[[^\]]+\]:\s*(<[^>]+>|\S+)")
FENCE_PATTERN = re.compile(r"^\s*(`{3,}|~{3,})")

errors = []


def error(path, message, line=None):
    location = str(path.relative_to(ROOT))

    if line is not None:
        location += f":{line}"

    errors.append(f"{location}: {message}")


def validate_frontmatter(path, directory):
    lines = path.read_text(encoding="utf-8-sig").splitlines()

    if not lines or lines[0].strip() != "---":
        error(path, "Missing YAML frontmatter")
        return

    closing = next(
        (i for i in range(1, len(lines)) if lines[i] == "---"),
        None,
    )

    if closing is None:
        error(path, "Unclosed YAML frontmatter")
        return

    fields = {}

    for index, line in enumerate(lines[1:closing], start=2):
        match = FIELD_PATTERN.match(line)

        if match:
            key, value = match.groups()

            if key in fields:
                error(path, f"Duplicate frontmatter field: {key}", index)

            fields[key] = value.strip().strip("\"'")

    name = fields.get("name", "")
    description = fields.get("description", "")

    if not name:
        error(path, "Missing name")
    elif not NAME_PATTERN.fullmatch(name):
        error(path, f"Invalid skill name: {name}")
    elif name != directory.name:
        error(path, f"Name '{name}' does not match directory '{directory.name}'")

    if not description:
        error(path, "Missing description")
    elif description in ("|", "|-", "|+", ">", ">-", ">+"):
        description_line = next(
            (
                line.strip()
                for line in lines[1:closing]
                if line.startswith((" ", "\t")) and line.strip()
            ),
            "",
        )

        if not description_line:
            error(path, "Empty multiline description")

    return name or None


def validate_link(path, target, line):
    target = target.strip()

    if target.startswith("<"):
        target = target[1:].split(">", 1)[0]
    else:
        target = target.split(maxsplit=1)[0] if target else ""

    if not target or target.startswith(("#", "/", "//")):
        return

    parsed = urlsplit(target)

    if parsed.scheme or parsed.netloc or not parsed.path:
        return

    destination = path.parent / unquote(parsed.path)

    if not destination.exists():
        error(path, f"Broken link: {target}", line)


def validate_links(path):
    fenced = None

    for number, line in enumerate(
        path.read_text(encoding="utf-8-sig").splitlines(),
        start=1,
    ):
        fence = FENCE_PATTERN.match(line)

        if fence:
            marker = fence.group(1)

            if fenced is None:
                fenced = marker
            elif marker[0] == fenced[0] and len(marker) >= len(fenced):
                fenced = None

            continue

        if fenced:
            continue

        line = re.sub(r"`[^`]*`", "", line)

        for match in LINK_PATTERN.finditer(line):
            validate_link(path, match.group(1), number)

        match = REFERENCE_PATTERN.match(line)

        if match:
            validate_link(path, match.group(1), number)


def main():
    if not SKILLS.is_dir():
        print("Missing skills/ directory")
        return 1

    names = set()
    directories = sorted(path for path in SKILLS.iterdir() if path.is_dir())

    if not directories:
        print("No skills found")
        return 1

    markdown_count = 0

    for directory in directories:
        skill_file = directory / "SKILL.md"

        if not skill_file.is_file():
            error(directory, "Missing SKILL.md")
        else:
            name = validate_frontmatter(skill_file, directory)

            if name:
                if name in names:
                    error(skill_file, f"Duplicate skill name: {name}")
                names.add(name)

        for markdown in directory.rglob("*.md"):
            validate_links(markdown)
            markdown_count += 1

    if errors:
        for message in errors:
            print(f"ERROR: {message}", file=sys.stderr)

        print(f"\nValidation failed: {len(errors)} error(s)")
        return 1

    print(
        f"Validation passed: {len(directories)} skills, {markdown_count} Markdown files"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
