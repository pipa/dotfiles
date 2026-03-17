#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract all information in a single jq call for performance
eval "$(echo "$input" | jq -r '
  @sh "model_name=\(.model.display_name // "unknown")",
  @sh "current_dir=\(.workspace.current_dir // "/")",
  @sh "context_size=\(.context_window.context_window_size // 200000)",
  @sh "current_tokens=\((.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0))",
  @sh "session_cost=\(.cost.total_cost_usd // 0)",
  @sh "active_tasks=\(.tasks.active_count // 0)",
  @sh "total_tasks=\(.tasks.total_count // 0)"
')"

# Calculate context percentage
context_percent=$((current_tokens * 100 / context_size))

# Build context progress bar (15 chars wide) using printf+tr for speed
bar_width=15
filled=$((context_percent * bar_width / 100))
empty=$((bar_width - filled))
bar="$(printf '%*s' "$filled" '' | tr ' ' '█')$(printf '%*s' "$empty" '' | tr ' ' '░')"

# Get directory name (basename)
dir_name=$(basename "$current_dir")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Color the context bar based on usage threshold
if [ "$context_percent" -ge 80 ]; then
    bar_color="$RED"
elif [ "$context_percent" -ge 50 ]; then
    bar_color="$YELLOW"
else
    bar_color="$GREEN"
fi

# Change to the current directory to get git info
cd "$current_dir" 2>/dev/null || cd /

# Get git branch and status
git_info=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "detached")

    status_output=$(git status --porcelain 2>/dev/null)

    if [ -n "$status_output" ]; then
        total_files=$(echo "$status_output" | wc -l | xargs)

        # Use diff against HEAD, fallback to diff against empty tree for initial commits
        if git rev-parse HEAD >/dev/null 2>&1; then
            line_stats=$(git diff --numstat HEAD 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+0, removed+0}')
        else
            line_stats=$(git diff --numstat --cached 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+0, removed+0}')
        fi

        added=$(echo $line_stats | cut -d' ' -f1)
        removed=$(echo $line_stats | cut -d' ' -f2)

        git_info=" ${YELLOW}($branch${NC} ${YELLOW}|${NC} ${GRAY}${total_files} files${NC}"
        [ "$added" -gt 0 ] && git_info="${git_info} ${GREEN}+${added}${NC}"
        [ "$removed" -gt 0 ] && git_info="${git_info} ${RED}-${removed}${NC}"
        git_info="${git_info} ${YELLOW})${NC}"
    else
        git_info=" ${YELLOW}($branch)${NC}"
    fi
fi

# Session cost display
cost_info=""
if [ -n "$session_cost" ] && [ "$session_cost" != "0" ]; then
    formatted_cost=$(printf "%.4f" "$session_cost")
    cost_info=" ${GRAY}[\${formatted_cost}]${NC}"
fi

# Task count display
task_info=""
if [ "$total_tasks" -gt 0 ]; then
    task_info=" ${GRAY}|${NC} ${CYAN}tasks: ${active_tasks}/${total_tasks}${NC}"
fi

# Build context bar display with color
context_info="${bar_color}${bar}${NC} ${context_percent}%"

# Output the status line
echo -e "${BLUE}${dir_name}${NC} ${GRAY}|${NC} ${CYAN}${model_name}${NC} ${GRAY}|${NC} ${context_info}${git_info:+ ${GRAY}|${NC}}${git_info}${cost_info}${task_info}"
