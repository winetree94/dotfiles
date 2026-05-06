---
description: Fast commit and push
agent: build
model: opencode-go/deepseek-v4-flash
subtask: true
---

Analyze current changes and create well-organized commits.

## Instructions

1. **Review project commit rules first**
   - Check for explicit project rules in files such as `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, or other project documentation, and review the last 10 git commits
   - Use this priority order:
     1. Explicit project commit rules
     2. Consistent commit conventions observed in recent project history
     3. Fallback rules in this prompt
   - If explicit project rules conflict with this prompt, follow the project rules

2. **Analyze current changes**
   - Run `git status` and `git diff` to understand all staged and unstaged changes
   - Group related changes by their purpose (e.g., feature work, bug fixes, documentation, refactoring)

3. **Split commits by purpose**
   - Do NOT create a single commit for unrelated changes
   - Create separate commits for each logical unit of work
   - Each commit should be atomic and represent a single purpose

4. **Commit message format**
   - If the project defines an explicit commit message format, follow it
   - Otherwise, if recent commits show a clear and consistent pattern, follow that pattern
   - Otherwise, fall back to this prompt's format and use a conventional commit prefix:
      - `feat:` - new features
      - `fix:` - bug fixes
      - `docs:` - documentation changes
     - `chore:` - maintenance tasks, dependency updates
     - `refactor:` - code refactoring without behavior change
     - `style:` - formatting, whitespace changes
     - `test:` - adding or updating tests
     - `i18n:` - internationalization changes
   - Write concise, descriptive messages focusing on "why" rather than "what"
   - Keep the subject line under 72 characters

5. **Push to remote**
   - After all commits are created, push to the remote repository

6. **Commit message language**
   - If the project defines an explicit commit message language rule, follow it
   - Otherwise, if recent commits consistently use one language, follow that language
   - Otherwise, fall back to English
   - When using English, use clear, professional technical English
   - Follow standard English grammar and sentence structure
   - Use imperative mood when writing English commit messages (e.g., "Add feature" not "Added feature")
   - English examples:
      - `feat: add user profile page`
      - `fix: resolve timeout error during login`
      - `docs: add installation guide to README`
      - `refactor: extract authentication logic into separate module`
