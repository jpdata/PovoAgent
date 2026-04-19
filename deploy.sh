#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# PovoAgent Deploy Script
#
# Deploys the AI framework (platform instructions, lifecycle skills, and
# technology pattern) into a target project.
#
# Usage:
#   ./deploy.sh -p copilot -t flutter -d /path/to/project
#   ./deploy.sh                  # interactive mode
#   ./deploy.sh -p copilot -t flutter -d /path/to/project -f   # force overwrite
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Resolve script root ─────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORMS_DIR="$SCRIPT_DIR/platforms"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
SKILLS_DIR="$SCRIPT_DIR/skills"

# ── Defaults ─────────────────────────────────────────────────────────────────
PLATFORM=""
PATTERN=""
TARGET=""
FORCE=false

# ── Parse arguments ──────────────────────────────────────────────────────────
while getopts "p:t:d:fh" opt; do
    case $opt in
        p) PLATFORM="$OPTARG" ;;
        t) PATTERN="$OPTARG" ;;
        d) TARGET="$OPTARG" ;;
        f) FORCE=true ;;
        h)
            echo "Usage: $0 [-p platform] [-t pattern] [-d target] [-f]"
            echo "  -p  AI platform: copilot | gemini | claude"
            echo "  -t  Technology pattern: flutter | dotnet"
            echo "  -d  Target project path"
            echo "  -f  Force overwrite existing files"
            exit 0
            ;;
        *) echo "Unknown option. Use -h for help." >&2; exit 1 ;;
    esac
done

# ── Colors ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m'

# ── Discovery ────────────────────────────────────────────────────────────────
get_platforms() {
    find "$PLATFORMS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

get_patterns() {
    find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d \
        ! -name "platforms" ! -name "skills" ! -name ".git" \
        ! -name ".github" ! -name ".gemini" ! -name "node_modules" \
        -exec sh -c 'test -f "$1/conventions.md" && basename "$1"' _ {} \; | sort
}

# ── Interactive selection ────────────────────────────────────────────────────
select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    echo ""
    echo -e "${CYAN}${prompt}${NC}"
    for i in "${!options[@]}"; do
        echo "  [$((i + 1))] ${options[$i]}"
    done
    while true; do
        read -rp "Select (1-${#options[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
            echo "${options[$((choice - 1))]}"
            return
        fi
        echo -e "  ${YELLOW}Invalid selection, try again.${NC}"
    done
}

mapfile -t AVAILABLE_PLATFORMS < <(get_platforms)
mapfile -t AVAILABLE_PATTERNS  < <(get_patterns)

if [[ -z "$PLATFORM" ]]; then
    PLATFORM=$(select_option "Select AI platform:" "${AVAILABLE_PLATFORMS[@]}")
fi
if [[ -z "$PATTERN" ]]; then
    PATTERN=$(select_option "Select technology pattern:" "${AVAILABLE_PATTERNS[@]}")
fi
if [[ -z "$TARGET" ]]; then
    echo ""
    read -rp "Target project path: " TARGET
fi

# ── Validation ───────────────────────────────────────────────────────────────
PLATFORM=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')
PATTERN=$(echo "$PATTERN" | tr '[:upper:]' '[:lower:]')

if [[ ! " ${AVAILABLE_PLATFORMS[*]} " =~ " ${PLATFORM} " ]]; then
    echo "Error: Unknown platform '$PLATFORM'. Available: ${AVAILABLE_PLATFORMS[*]}" >&2
    exit 1
fi
if [[ ! " ${AVAILABLE_PATTERNS[*]} " =~ " ${PATTERN} " ]]; then
    echo "Error: Unknown pattern '$PATTERN'. Available: ${AVAILABLE_PATTERNS[*]}" >&2
    exit 1
fi
if [[ ! -d "$TARGET" ]]; then
    echo "Error: Target path does not exist: $TARGET" >&2
    exit 1
fi

# ── Deploy helpers ───────────────────────────────────────────────────────────
TOTAL_FILES=0

copy_tree_safe() {
    local source="$1"
    local destination="$2"
    local label="$3"
    local count=0

    if [[ ! -d "$source" ]]; then
        echo -e "  ${GRAY}[SKIP] ${label} — source not found: ${source}${NC}"
        return
    fi

    while IFS= read -r -d '' file; do
        local rel_path="${file#"$source"/}"
        local dest_file="$destination/$rel_path"
        local dest_dir
        dest_dir="$(dirname "$dest_file")"

        if [[ -f "$dest_file" ]] && [[ "$FORCE" != true ]]; then
            echo -e "  ${YELLOW}[EXISTS] ${rel_path} — use -f to overwrite${NC}"
            continue
        fi

        mkdir -p "$dest_dir"
        cp "$file" "$dest_file"
        count=$((count + 1))
    done < <(find "$source" -type f -print0)

    TOTAL_FILES=$((TOTAL_FILES + count))
}

# ── Platform-specific deploy targets ────────────────────────────────────────
get_agents_dir() {
    case "$1" in
        copilot) echo ".github/agents" ;;
        gemini)  echo ".gemini/agents" ;;
        claude)  echo ".claude/agents" ;;
    esac
}

get_skills_dir() {
    case "$1" in
        copilot) echo ".github/skills" ;;
        gemini)  echo ".gemini/skills" ;;
        claude)  echo ".claude/skills" ;;
    esac
}

AGENTS_DIR=$(get_agents_dir "$PLATFORM")
SKILLS_TARGET_DIR=$(get_skills_dir "$PLATFORM")

# ── Execute deploy ───────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  PovoAgent Deploy${NC}"
echo -e "${WHITE}  Platform : ${PLATFORM}${NC}"
echo -e "${WHITE}  Pattern  : ${PATTERN}${NC}"
echo -e "${WHITE}  Target   : ${TARGET}${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""

# 1. Platform instructions template
echo -e "${CYAN}[1/5] Platform instructions (${PLATFORM})...${NC}"
PLATFORM_SOURCE="$PLATFORMS_DIR/$PLATFORM"
copy_tree_safe "$PLATFORM_SOURCE" "$TARGET" "Platform template"

# 2. Agent template
echo -e "${CYAN}[2/5] Agent template...${NC}"
AGENT_SOURCE="$TEMPLATES_DIR/agent.md"
if [[ -f "$AGENT_SOURCE" ]]; then
    AGENT_DEST="$TARGET/agent.md"
    if [[ -f "$AGENT_DEST" ]] && [[ "$FORCE" != true ]]; then
        echo -e "  ${YELLOW}[EXISTS] agent.md - use -f to overwrite${NC}"
    else
        cp "$AGENT_SOURCE" "$AGENT_DEST"
        TOTAL_FILES=$((TOTAL_FILES + 1))
    fi
fi

# 3. Lifecycle skills (generic)
echo -e "${CYAN}[3/5] Lifecycle skills...${NC}"
copy_tree_safe "$SKILLS_DIR" "$TARGET/$SKILLS_TARGET_DIR" "Lifecycle skills"

# 4. Pattern conventions
echo -e "${CYAN}[4/5] Pattern conventions (${PATTERN})...${NC}"
PATTERN_DIR="$SCRIPT_DIR/$PATTERN"
CONVENTIONS_SOURCE="$PATTERN_DIR/conventions.md"
if [[ -f "$CONVENTIONS_SOURCE" ]]; then
    CONVENTIONS_DEST="$TARGET/conventions.md"
    if [[ -f "$CONVENTIONS_DEST" ]] && [[ "$FORCE" != true ]]; then
        echo -e "  ${YELLOW}[EXISTS] conventions.md — use -f to overwrite${NC}"
    else
        cp "$CONVENTIONS_SOURCE" "$CONVENTIONS_DEST"
        TOTAL_FILES=$((TOTAL_FILES + 1))
    fi
else
    echo -e "  ${GRAY}[SKIP] conventions.md not found${NC}"
fi

# 5. Pattern agents & skills
echo -e "${CYAN}[5/5] Pattern agents & skills (${PATTERN})...${NC}"
copy_tree_safe "$PATTERN_DIR/agents" "$TARGET/$AGENTS_DIR" "Pattern agents"
copy_tree_safe "$PATTERN_DIR/skills" "$TARGET/$SKILLS_TARGET_DIR" "Pattern skills"

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Deploy complete — ${TOTAL_FILES} file(s) copied.${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""
