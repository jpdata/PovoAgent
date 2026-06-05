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
            echo "Usage: $0 [-p platform] [-t pattern[,pattern2,...]] [-d target] [-f]"
            echo "  -p  AI platform: copilot | gemini | claude"
            echo "  -t  Technology pattern(s): flutter | dotnet | angular | react | astro"
            echo "      Accepts comma-separated values: -t flutter,dotnet"
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

select_multiple() {
    local prompt="$1"
    shift
    local options=("$@")
    echo ""
    echo -e "${CYAN}${prompt}${NC}"
    for i in "${!options[@]}"; do
        echo "  [$((i + 1))] ${options[$i]}"
    done
    echo -e "  ${GRAY}Enter one or more numbers separated by commas (e.g. 1,3)${NC}"
    while true; do
        read -rp "Select: " choice
        local result=()
        local valid=true
        IFS=',' read -ra parts <<< "$choice"
        for part in "${parts[@]}"; do
            part="${part// /}"
            if [[ "$part" =~ ^[0-9]+$ ]] && (( part >= 1 && part <= ${#options[@]} )); then
                result+=("${options[$((part - 1))]}")
            else
                valid=false
                break
            fi
        done
        if [[ "$valid" == true ]] && [[ ${#result[@]} -gt 0 ]]; then
            printf '%s\n' "${result[@]}"
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
    mapfile -t selected_patterns < <(select_multiple "Select technology pattern(s):" "${AVAILABLE_PATTERNS[@]}")
    PATTERN=$(IFS=','; echo "${selected_patterns[*]}")
fi
if [[ -z "$TARGET" ]]; then
    echo ""
    read -rp "Target project path: " TARGET
fi

# ── Validation ───────────────────────────────────────────────────────────────
PLATFORM=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')
PATTERN=$(echo "$PATTERN" | tr '[:upper:]' '[:lower:]')
IFS=',' read -ra PATTERNS <<< "$PATTERN"
for i in "${!PATTERNS[@]}"; do
    PATTERNS[$i]="${PATTERNS[$i]// /}"
done

if [[ ! " ${AVAILABLE_PLATFORMS[*]} " =~ " ${PLATFORM} " ]]; then
    echo "Error: Unknown platform '$PLATFORM'. Available: ${AVAILABLE_PLATFORMS[*]}" >&2
    exit 1
fi
for pat in "${PATTERNS[@]}"; do
    if [[ ! " ${AVAILABLE_PATTERNS[*]} " =~ " ${pat} " ]]; then
        echo "Error: Unknown pattern '$pat'. Available: ${AVAILABLE_PATTERNS[*]}" >&2
        exit 1
    fi
done
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
        copilot)  echo ".github/agents" ;;
        gemini)   echo ".gemini/agents" ;;
        claude)   echo ".claude/agents" ;;
        opencode) echo ".opencode/agents" ;;
    esac
}

get_skills_dir() {
    case "$1" in
        copilot)  echo ".github/skills" ;;
        gemini)   echo ".gemini/skills" ;;
        claude)   echo ".claude/skills" ;;
        opencode) echo ".opencode/skills" ;;
    esac
}

AGENTS_DIR=$(get_agents_dir "$PLATFORM")
SKILLS_TARGET_DIR=$(get_skills_dir "$PLATFORM")

# ── Execute deploy ───────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  PovoAgent Deploy${NC}"
echo -e "${WHITE}  Platform : ${PLATFORM}${NC}"
echo -e "${WHITE}  Patterns : $(IFS=', '; echo "${PATTERNS[*]}")${NC}"
echo -e "${WHITE}  Target   : ${TARGET}${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""

# 1. Platform instructions template
echo -e "${CYAN}[1/6] Platform instructions (${PLATFORM})...${NC}"
PLATFORM_SOURCE="$PLATFORMS_DIR/$PLATFORM"
copy_tree_safe "$PLATFORM_SOURCE" "$TARGET" "Platform template"

# 2. Agent template
echo -e "${CYAN}[2/6] Agent template...${NC}"
PLATFORM_AGENT_SOURCE="$TEMPLATES_DIR/$PLATFORM/povo.agent.md"
if [[ -f "$PLATFORM_AGENT_SOURCE" ]]; then
    AGENT_SOURCE="$PLATFORM_AGENT_SOURCE"
else
    AGENT_SOURCE="$TEMPLATES_DIR/povo.agent.md"
fi
if [[ -f "$AGENT_SOURCE" ]]; then
    AGENT_DEST_DIR="$TARGET/$AGENTS_DIR"
    mkdir -p "$AGENT_DEST_DIR"
    AGENT_DEST="$AGENT_DEST_DIR/povo.agent.md"
    if [[ -f "$AGENT_DEST" ]] && [[ "$FORCE" != true ]]; then
        echo -e "  ${YELLOW}[EXISTS] povo.agent.md - use -f to overwrite${NC}"
    else
        cp "$AGENT_SOURCE" "$AGENT_DEST"
        TOTAL_FILES=$((TOTAL_FILES + 1))
    fi
fi

# 3. Lifecycle skills (generic)
echo -e "${CYAN}[3/6] Lifecycle skills...${NC}"
copy_tree_safe "$SKILLS_DIR" "$TARGET/$SKILLS_TARGET_DIR" "Lifecycle skills"

# 4. Pattern conventions
MULTI_PATTERN=false
[[ ${#PATTERNS[@]} -gt 1 ]] && MULTI_PATTERN=true
echo -e "${CYAN}[4/6] Pattern conventions ($(IFS=', '; echo "${PATTERNS[*]}"))...${NC}"
for pat in "${PATTERNS[@]}"; do
    PATTERN_DIR="$SCRIPT_DIR/$pat"
    CONVENTIONS_SOURCE="$PATTERN_DIR/conventions.md"
    if [[ "$MULTI_PATTERN" == true ]]; then
        CONVENTIONS_NAME="conventions-${pat}.md"
    else
        CONVENTIONS_NAME="conventions.md"
    fi
    if [[ -f "$CONVENTIONS_SOURCE" ]]; then
        CONVENTIONS_DEST="$TARGET/$CONVENTIONS_NAME"
        if [[ -f "$CONVENTIONS_DEST" ]] && [[ "$FORCE" != true ]]; then
            echo -e "  ${YELLOW}[EXISTS] ${CONVENTIONS_NAME} — use -f to overwrite${NC}"
        else
            cp "$CONVENTIONS_SOURCE" "$CONVENTIONS_DEST"
            TOTAL_FILES=$((TOTAL_FILES + 1))
        fi
    else
        echo -e "  ${GRAY}[SKIP] ${CONVENTIONS_NAME} not found${NC}"
    fi
done

# 5. Pattern agents & skills
echo -e "${CYAN}[5/6] Pattern agents & skills ($(IFS=', '; echo "${PATTERNS[*]}"))...${NC}"
for pat in "${PATTERNS[@]}"; do
    PATTERN_DIR="$SCRIPT_DIR/$pat"
    copy_tree_safe "$PATTERN_DIR/agents" "$TARGET/$AGENTS_DIR" "Pattern agents ($pat)"
    copy_tree_safe "$PATTERN_DIR/skills" "$TARGET/$SKILLS_TARGET_DIR" "Pattern skills ($pat)"
done

# 6. Update .gitignore
echo -e "${CYAN}[6/6] Updating .gitignore...${NC}"

if [[ ! -d "$TARGET/.git" ]]; then
    echo -e "  ${YELLOW}[WARN] No git repository detected at '$TARGET'.${NC}"
    echo -e "  ${YELLOW}       Run 'git init' first so .gitignore takes effect.${NC}"
fi

# Collect deployed paths relative to target
IGNORE_ENTRIES=()

# Platform template files
if [[ -d "$PLATFORM_SOURCE" ]]; then
    while IFS= read -r -d '' file; do
        rel="${file#"$PLATFORM_SOURCE"/}"
        IGNORE_ENTRIES+=("/$rel")
    done < <(find "$PLATFORM_SOURCE" -type f -print0)
fi

# Main agent
IGNORE_ENTRIES+=("/$AGENTS_DIR/povo.agent.md")

# Lifecycle skills (as directories)
if [[ -d "$SKILLS_DIR" ]]; then
    while IFS= read -r -d '' dir; do
        dirname="$(basename "$dir")"
        IGNORE_ENTRIES+=("/$SKILLS_TARGET_DIR/$dirname/")
    done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
fi

# Conventions
for pat in "${PATTERNS[@]}"; do
    if [[ "$MULTI_PATTERN" == true ]]; then
        IGNORE_ENTRIES+=("/conventions-${pat}.md")
    else
        IGNORE_ENTRIES+=("/conventions.md")
    fi
done

# Pattern agents and skills
for pat in "${PATTERNS[@]}"; do
    PATTERN_DIR="$SCRIPT_DIR/$pat"
    PATTERN_AGENTS_DIR="$PATTERN_DIR/agents"
    if [[ -d "$PATTERN_AGENTS_DIR" ]]; then
        while IFS= read -r -d '' file; do
            rel="${file#"$PATTERN_AGENTS_DIR"/}"
            IGNORE_ENTRIES+=("/$AGENTS_DIR/$rel")
        done < <(find "$PATTERN_AGENTS_DIR" -type f -print0)
    fi
    PATTERN_SKILLS_DIR="$PATTERN_DIR/skills"
    if [[ -d "$PATTERN_SKILLS_DIR" ]]; then
        while IFS= read -r -d '' dir; do
            dirname="$(basename "$dir")"
            IGNORE_ENTRIES+=("/$SKILLS_TARGET_DIR/$dirname/")
        done < <(find "$PATTERN_SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
    fi
done

# Sort and deduplicate
mapfile -t IGNORE_ENTRIES < <(printf '%s\n' "${IGNORE_ENTRIES[@]}" | sort -u)

# Write to .gitignore with markers
GITIGNORE_PATH="$TARGET/.gitignore"
MARKER_BEGIN="# -- PovoAgent BEGIN --"
MARKER_END="# -- PovoAgent END --"

# Build new block
NEW_BLOCK="$MARKER_BEGIN"
for entry in "${IGNORE_ENTRIES[@]}"; do
    NEW_BLOCK="$NEW_BLOCK"$'\n'"$entry"
done
NEW_BLOCK="$NEW_BLOCK"$'\n'"$MARKER_END"

if [[ -f "$GITIGNORE_PATH" ]]; then
    if grep -qF "$MARKER_BEGIN" "$GITIGNORE_PATH"; then
        # Replace existing block
        tmpfile=$(mktemp)
        awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" -v block="$NEW_BLOCK" '
            $0 == begin { print block; skip=1; next }
            $0 == end { skip=0; next }
            !skip { print }
        ' "$GITIGNORE_PATH" > "$tmpfile"
        mv "$tmpfile" "$GITIGNORE_PATH"
        echo -e "  ${WHITE}[UPDATED] .gitignore (PovoAgent section replaced)${NC}"
    else
        # Append new block
        printf '\n%s\n' "$NEW_BLOCK" >> "$GITIGNORE_PATH"
        echo -e "  ${WHITE}[UPDATED] .gitignore (PovoAgent section added)${NC}"
    fi
else
    printf '%s\n' "$NEW_BLOCK" > "$GITIGNORE_PATH"
    echo -e "  ${WHITE}[CREATED] .gitignore${NC}"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Deploy complete — ${TOTAL_FILES} file(s) copied.${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""
