# Repo Summarizer

A shell script that generates comprehensive summaries of codebases to aid in project understanding and documentation.

## Benefits

- Quick assessment of project scope and complexity
- Easy sharing of project overviews with team members
- Enhanced context for AI/LLM interactions
- Streamlined onboarding and code review preparation

## Usage

```bash
bash repo_summarizer.sh [DIRECTORY] [-e|--exclude PATH]...
```

Arguments:

- `DIRECTORY`: Target project directory (default: current directory)
- `-e, --exclude PATH`: Directories/files to exclude

Example:

```bash
bash repo_summarizer.sh myproject -e docs -e tests
```

Shell Integration:

```bash
# Add to .zshrc or equivalent
rsum() {
  bash /Users/mitchfultz/Projects/Scripts/RepoSummarizer/repo_summarizer.sh "$@"
  pbcopy <repo_summary.txt
}
```

## Features

- Configurable output location and directory scanning
- Smart file pattern matching for relevant code files
- Exclusion of build artifacts, cache, and generated content
- Generation of tree structure and content summaries
- Statistical analysis (file count, LOC, file types)

## Roadmap

- [ ] AI version that automatically determines which files to include/exclude
- [ ] Additional file type support
- [ ] Parallel processing implementation
- [ ] Enhanced metrics and statistics
- [ ] Multiple output format options
- [ ] Improved error handling

## Version: 1.0.0

Licensed under MIT
