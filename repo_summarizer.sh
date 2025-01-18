#!/bin/bash

# ────────────────────────────────────────────────────────────────────────────────
#  CONFIGURATION
# ────────────────────────────────────────────────────────────────────────────────

# Script identification
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_VERSION="1.0.0"

# Default settings
readonly DEFAULT_OUTPUT_FILE="repo_summary.txt"
readonly DEFAULT_DIRECTORY="."

# User settings (can be overridden)
OUTPUT_FILE="$DEFAULT_OUTPUT_FILE"
DIRECTORY="$DEFAULT_DIRECTORY"

# ────────────────────────────────────────────────────────────────────────────────
#  FILE PATTERNS
# ────────────────────────────────────────────────────────────────────────────────

# Files to include (grouped by type for easier modification)
readonly BACKEND_FILES=(
    "*.py" "*.ipynb" "requirements.txt" "setup.py" "pyproject.toml"
)

readonly FRONTEND_FILES=(
    "*.js" "*.jsx" "*.ts" "*.tsx" "*.mjs"
    "*.html" "*.css" "*.scss" "*.sass" "*.less"
)

readonly CONFIG_FILES=(
    "*.json" "*.yaml" "*.yml" "*.prisma"
    "*.env*" "Dockerfile" "docker-compose*.yml"
)

readonly DOC_FILES=(
    "*.md" "*.sh"
)

# Combine all patterns
INCLUDE_PATTERNS=(
    "${BACKEND_FILES[@]}"
    "${FRONTEND_FILES[@]}"
    "${CONFIG_FILES[@]}"
    "${DOC_FILES[@]}"
)

# ────────────────────────────────────────────────────────────────────────────────
#  EXCLUSION PATTERNS
# ────────────────────────────────────────────────────────────────────────────────

# Directories to exclude (grouped by purpose)
readonly BUILD_DIRS=(
    "node_modules" "dist" "build" ".next" ".webpack" ".serverless"
    "public/build" "public/dist" "storybook-static" ".storybook-out"
)

readonly TOOL_DIRS=(
    ".git" ".idea" ".vscode"
)

readonly CACHE_DIRS=(
    "coverage" "__pycache__" ".pytest_cache" ".mypy_cache"
    ".turbo" ".swc" ".cache" "mlx_models"
)

readonly ENV_DIRS=(
    "venv" ".venv" "target" "out" "bin" "obj"
)

readonly GENERATED_DIRS=(
    "migrations" "__snapshots__" "prisma/client"
    ".vercel"
    "__blobstorage__" "__queuestorage__"
    "tesseract_libs"
)

# Files to exclude (grouped by type)
readonly PACKAGE_FILES=(
    "package-lock.json" "yarn.lock" "pnpm-lock.yaml"
    ".npmrc"
    "npm-debug.log*" "yarn-debug.log*" "yarn-error.log*"
    ".pnpm-debug.log*"
)

readonly BUILD_FILES=(
    "*.pyc" "*.pyo" "*.pyd" "*.so" ".Python"
    "*.tsbuildinfo"
    "*.min.js" "*.min.css"
    "*.map" "*.d.ts.map" "*.js.map"
    "*.generated.*" "schema.generated.ts"
    "asset-manifest.json"
    "stats.json"
)

readonly SYSTEM_FILES=(
    ".DS_Store"
    "$SCRIPT_NAME"
    "LICENSE"
    "__azurite_db_*.json"
    "azdps-docai-3532ea781451.json"
    "$DEFAULT_OUTPUT_FILE"
)

# Combine all exclusions
EXCLUDE_DIRS=(
    "${BUILD_DIRS[@]}"
    "${TOOL_DIRS[@]}"
    "${CACHE_DIRS[@]}"
    "${ENV_DIRS[@]}"
    "${GENERATED_DIRS[@]}"
)

EXCLUDE_FILES=(
    "${PACKAGE_FILES[@]}"
    "${BUILD_FILES[@]}"
    "${SYSTEM_FILES[@]}"
)

# ────────────────────────────────────────────────────────────────────────────────
#  HELPER FUNCTIONS
# ────────────────────────────────────────────────────────────────────────────────

function usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [DIRECTORY] [-e|--exclude PATH]...

Creates a '$DEFAULT_OUTPUT_FILE' with included files from DIRECTORY.

Options:
  DIRECTORY                The project directory to scan (default: current dir)
  -e, --exclude PATH      Exclude PATH (directory or file) from the summary
  -h, --help             Show this help message

Examples:
  $SCRIPT_NAME                     # Scan current directory
  $SCRIPT_NAME myproject          # Scan './myproject'
  $SCRIPT_NAME -e docs -e tests   # Exclude additional dirs

Version: $SCRIPT_VERSION
EOF
    exit 1
}

function check_venv() {
    if find "$DIRECTORY" -type d \( -name "venv" -o -name ".venv" \) | grep -q .; then
        echo "[✓] Python virtual environment detected"
    else
        echo "[✗] No Python virtual environment found"
    fi
}

# ────────────────────────────────────────────────────────────────────────────────
#  ARGUMENT PARSING
# ────────────────────────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
    -e | --exclude)
        if [[ -z "$2" ]]; then
            echo "Error: --exclude requires a parameter."
            usage
        fi
        EXCLUDE_DIRS+=("$2")
        EXCLUDE_FILES+=("$2")
        shift 2
        ;;
    -h | --help)
        usage
        ;;
    *)
        DIRECTORY="$1"
        shift
        ;;
    esac
done

# ────────────────────────────────────────────────────────────────────────────────
#  MAIN LOGIC
# ────────────────────────────────────────────────────────────────────────────────

# Clear the output file
>"$OUTPUT_FILE"

# Get the absolute path of the directory
ABSOLUTE_PATH=$(realpath "$DIRECTORY")

# Get the base directory name
PROJECT_NAME=$(basename "$ABSOLUTE_PATH")

# Start the output file
{
    echo "===== Project: $PROJECT_NAME ====="
    echo "Directory: $ABSOLUTE_PATH"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "\n"
    echo "===== Project Structure ====="
    echo ""
    check_venv
    echo ""

    # Generate tree structure
    tree -I "$(
        IFS='|'
        echo "${EXCLUDE_DIRS[*]}"
    )" "$DIRECTORY"
    echo -e "\n\n"
} >>"$OUTPUT_FILE"

# Build and execute find command
FIND_CMD="find \"$DIRECTORY\" -type f \( "
for pattern in "${INCLUDE_PATTERNS[@]}"; do
    FIND_CMD+=" -name \"$pattern\" -o"
done
FIND_CMD="${FIND_CMD% -o} \)"

for dir in "${EXCLUDE_DIRS[@]}"; do
    FIND_CMD+=" -not -path \"*/$dir/*\""
done

for file in "${EXCLUDE_FILES[@]}"; do
    FIND_CMD+=" -not -name \"$file\""
done

# Process files
eval "$FIND_CMD" | while IFS= read -r file; do
    {
        echo "===== $file ====="
        cat "$file"
        echo -e "\n\n"
    } >>"$OUTPUT_FILE"
done

# Generate and add summary statistics
{
    echo "===== Summary Statistics ====="
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Project: $PROJECT_NAME"
    echo "Directory: $ABSOLUTE_PATH"
    echo ""

    # Count total files processed
    total_files=$(eval "$FIND_CMD" | wc -l)
    printf "Total files processed: %6d\n" "$total_files"

    # Count lines of code
    total_lines=$(eval "$FIND_CMD" | xargs cat 2>/dev/null | wc -l)
    printf "Total lines of code: %8d\n" "$total_lines"

    echo -e "\nFile types:"
    eval "$FIND_CMD" | while read -r file; do
        basename=$(basename "$file")
        if [[ "$basename" == "Dockerfile" ]]; then
            echo "Dockerfile"
        elif [[ "$basename" == *"."* ]]; then
            echo "${basename##*.}"
        else
            echo "$basename"
        fi
    done | sort | uniq -c | sort -nr | while read -r count type; do
        # Pad the count for alignment
        printf "  %-6d %s\n" "$count" "$type"
    done

    # Get total size
    total_size=$(eval "$FIND_CMD" | xargs stat -f%z 2>/dev/null | awk '{total += $1} END {print total}')
    echo -e "\nTotal size: $(numfmt --to=iec-i --suffix=B $total_size)"

    echo -e "\nExcluded directories: ${#EXCLUDE_DIRS[@]}"
    echo "Excluded files: ${#EXCLUDE_FILES[@]}"

} >>"$OUTPUT_FILE"

echo "Repo summary created in $OUTPUT_FILE"
