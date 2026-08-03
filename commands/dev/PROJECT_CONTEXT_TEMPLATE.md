# PROJECT_CONTEXT.md Template

> Copy the content below into `PROJECT_CONTEXT.md` at your project root and fill in the actual values.
> The `/dev` skill reads this file at every Phase to restore context.

---

```markdown
# PROJECT_CONTEXT

## Repository Info
- **Repo URL**: https://github.com/[owner]/[repo]
- **Main branch**: main
- **Created**: YYYY-MM-DD

## Tech Stack
- **Language**: Python 3.11 / Node.js 20 / ...
- **Framework**: FastAPI / Express / ...
- **Database**: PostgreSQL / SQLite / ...
- **Test framework**: pytest / Jest / None

## Architecture Decisions
<!-- Add a "why" line when the decision is hard to reverse, surprising without context,
     AND the result of a real trade-off (all three — see grilling.md). -->
- **Auth scheme**: JWT, stored in HttpOnly Cookie / localStorage
  - why: mobile client can't use session cookies; refresh rotation chosen over long-lived tokens
- **API spec**: RESTful, error format `{"error_code": "...", "message": "..."}`, pagination via `?page=&size=`
- **Database migration framework**: Alembic (has existing data) / None (brand new project)
- **API Contract doc**: `API_CONTRACT.md` (exists for full-stack projects)

## Domain Glossary
<!-- Terminology only — never implementation details. Update the moment a term is resolved
     during Phase 1/2 grilling; challenge new requirements against this list. -->
- **Customer**: the paying organization (billing entity); distinct from **User**
- **User**: an individual login belonging to a Customer
- **[Term]**: [one-sentence canonical definition; note near-synonyms it must NOT be confused with]

## Code Style Conventions
- **Naming**: Python snake_case, class names PascalCase
- **Directory structure**:
  ```
  src/
    routers/    # API routing layer
    services/   # Business logic layer
    models/     # Data models
    utils/      # Utility functions
  tests/
  ```
- **Error handling convention**: always raise HTTPException, no business logic in the routing layer

## Completed Features
- [ ] Example: user registration/login (PR #3, merged 2024-01-15)
- [ ] Example: product listing API (PR #5, merged 2024-01-20)

## Current Status
- **Last updated**: YYYY-MM-DD
- **Git autonomy**: Gated / PR auto / Full auto  <!-- see Git Autonomy Gate in dev.md; asked once, user can change any time -->
- **Current iteration goal**: [description of features to complete this round]
- **Known tech debt**: [if any]
- **Open PRs**: #N [description], #M [description]
```
