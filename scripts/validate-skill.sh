#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Worxphere Skill Validator
#
# Usage:
#   bash validate-skill.sh <path-to-SKILL.md>
#   bash validate-skill.sh skills/          # validate all skills in directory
#
# Checks:
#   1. File exists and is readable
#   2. YAML frontmatter present (--- delimiters)
#   3. Required fields: name, description
#   4. name is kebab-case
#   5. File has content after frontmatter
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_skill() {
  local file="$1"
  local name
  local errors=0

  # 1. File exists
  if [[ ! -f "$file" ]]; then
    echo -e "${RED}[FAIL]${NC} $file — file not found"
    ((FAIL++))
    return 1
  fi

  # 2. YAML frontmatter
  local first_line
  first_line=$(head -1 "$file")
  if [[ "$first_line" != "---" ]]; then
    echo -e "${RED}[FAIL]${NC} $file — missing YAML frontmatter (first line must be ---)"
    ((FAIL++))
    return 1
  fi

  local fm_end
  fm_end=$(awk 'NR>1 && /^---$/{print NR; exit}' "$file")
  if [[ -z "$fm_end" ]]; then
    echo -e "${RED}[FAIL]${NC} $file — unclosed YAML frontmatter (missing closing ---)"
    ((FAIL++))
    return 1
  fi

  # 3. Required field: name
  name=$(awk "NR>1 && NR<$fm_end" "$file" | grep -m1 "^name:" | sed 's/name: *//' | tr -d '"' | tr -d "'")
  if [[ -z "$name" ]]; then
    echo -e "${RED}[FAIL]${NC} $file — missing required field: name"
    ((errors++))
  fi

  # 3. Required field: description
  local desc
  desc=$(awk "NR>1 && NR<$fm_end" "$file" | grep -m1 "^description:" | sed 's/description: *//' | tr -d '"')
  if [[ -z "$desc" ]]; then
    echo -e "${RED}[FAIL]${NC} $file — missing required field: description"
    ((errors++))
  fi

  # 4. name is kebab-case
  if [[ -n "$name" ]] && ! echo "$name" | grep -qE '^[a-z][a-z0-9-]*$'; then
    echo -e "${YELLOW}[WARN]${NC} $file — name '$name' is not kebab-case"
    ((WARN++))
  fi

  # 5. Content after frontmatter
  local total_lines
  total_lines=$(wc -l < "$file")
  if [[ "$total_lines" -le "$fm_end" ]]; then
    echo -e "${YELLOW}[WARN]${NC} $file — no content after frontmatter"
    ((WARN++))
  fi

  # Optional: triggers
  local has_triggers
  has_triggers=$(awk "NR>1 && NR<$fm_end" "$file" | grep -c "^triggers:" || true)
  if [[ "$has_triggers" -eq 0 ]]; then
    echo -e "${YELLOW}[WARN]${NC} $file — no triggers defined (recommended)"
    ((WARN++))
  fi

  if [[ "$errors" -gt 0 ]]; then
    ((FAIL += errors))
    return 1
  fi

  echo -e "${GREEN}[ OK ]${NC} $file — $name: $desc"
  ((PASS++))
  return 0
}

# Main
TARGET="${1:-.}"

if [[ -d "$TARGET" ]]; then
  # Validate all SKILL.md files in directory
  found=0
  while IFS= read -r -d '' file; do
    check_skill "$file"
    ((found++))
  done < <(find "$TARGET" -name "SKILL.md" -print0 | sort -z)

  if [[ "$found" -eq 0 ]]; then
    echo "No SKILL.md files found in $TARGET"
    exit 1
  fi
elif [[ -f "$TARGET" ]]; then
  check_skill "$TARGET"
else
  echo "Usage: validate-skill.sh <path-to-SKILL.md or directory>"
  exit 1
fi

# Summary
echo ""
echo "────────────────────"
echo -e "Pass: ${GREEN}$PASS${NC}  Warn: ${YELLOW}$WARN${NC}  Fail: ${RED}$FAIL${NC}"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
