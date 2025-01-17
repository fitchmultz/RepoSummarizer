# Repo Summarizer

## Overview

The `repo_summarizer.sh` script is a tool designed to generate a comprehensive summary of a project's codebase. It scans the specified directory, includes files based on predefined patterns, and excludes certain directories and files to create a detailed summary report.

## Why This is Useful

The `repo_summarizer.sh` script is particularly useful for developers and teams who need to quickly understand the structure and contents of a codebase. By generating a comprehensive summary, it allows users to:

- **Quickly Assess Project Scope**: Understand the size and complexity of a project by reviewing the number of files, lines of code, and file types.
- **Facilitate Communication**: Share a concise overview of the project with team members or stakeholders without needing to manually compile information.
- **Enhance Context for LLMs**: When interacting with language models, providing a detailed project summary can improve the model's understanding and response quality by offering context about the codebase.

This makes it an invaluable tool for onboarding new team members, preparing for code reviews, or integrating with AI tools that require contextual information about the project.

## How It Works

- **Configuration**: The script uses default settings for output file and directory, which can be overridden by user input.
- **File Patterns**: It includes backend, frontend, config, and documentation files while excluding build, tool, cache, environment, and generated directories.
- **Execution**: The script generates a tree structure of the project, processes files to include their content in the summary, and calculates summary statistics like total files, lines of code, and file types.

## Usage

To run the script, use the following command:

```bash
bash repo_summarizer.sh [DIRECTORY] [-e|--exclude PATH]...
```

- `DIRECTORY`: The project directory to scan (default: current directory).
- `-e, --exclude PATH`: Exclude specific directories or files from the summary.

## Example

```bash
bash repo_summarizer.sh myproject -e docs -e tests
```

This command scans the `myproject` directory, excluding `docs` and `tests` directories.

## Integration Tip

To easily use the script, add the following function to your `.zshrc` or equivalent shell configuration file:

```bash
rsum() {
  bash /Users/mitchfultz/Projects/Scripts/RepoSummarizer/repo_summarizer.sh "$@"
  pbcopy <repo_summary.txt
}
```

This function runs the script and copies the output to the clipboard for easy pasting.

## To-Do List

- [ ] Add support for more file types.
- [ ] Implement parallel processing for faster execution.
- [ ] Enhance summary statistics with more detailed metrics.
- [ ] Add options for different output formats (e.g., JSON, HTML).
- [ ] Improve error handling and logging.

## Version

Current version: 1.0.0

## License

This project is licensed under the MIT License.
