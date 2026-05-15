---
description: Commit
---

Analyze current changes and create well-organized commits.

## Instructions

1. **Review recent commit history**
   - Check the last 10 git commits to understand the project's commit message style and conventions
   - Follow the same format, tone, and structure for consistency

2. **Analyze current changes**
   - Run `git status` and `git diff` to understand all staged and unstaged changes
   - Group related changes by their purpose (e.g., feature work, bug fixes, documentation, refactoring)

3. **Split commits by purpose**
   - Do NOT create a single commit for unrelated changes
   - Create separate commits for each logical unit of work
   - Each commit should be atomic and represent a single purpose

4. **Commit message format**
   - Use a conventional commit prefix:
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


6. **Use Korean**
   - All commit messages MUST be written in Korean
   - Use natural Korean expressions, not direct translations
   - Follow Korean grammar and sentence structure
   - Examples:
     - `feat: 사용자 프로필 페이지 추가`
     - `fix: 로그인 시 발생하는 타임아웃 오류 해결`
     - `docs: README에 설치 가이드 추가`
     - `refactor: 인증 로직을 별도 모듈로 분리`


