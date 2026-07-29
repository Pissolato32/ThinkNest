# ThinkNest Documentation Standard

**Version:** 1.0
**Status:** Approved
**Scope:** All Markdown documentation under `docs/`
**Last reviewed:** 2026-07-29

## Purpose

This standard defines the quality bar for ThinkNest documentation. It turns the documentation set into a usable product surface: easy to navigate, safe to implement from, and clear enough for product, design, engineering, security, QA, and operations reviewers.

## AAA documentation rubric

| Level | Requirement | Reviewer question |
| --- | --- | --- |
| Accurate | Claims are traceable to specifications, ADRs, user journeys, acceptance criteria, or explicit assumptions. | Can a reviewer identify where the rule comes from? |
| Actionable | The document names expected behavior, constraints, edge cases, and handoff points. | Can an implementer make the next decision without guessing? |
| Accessible | Structure, language, links, and tables support fast scanning and assistive technologies. | Can a new contributor find and understand the answer quickly? |

## Required structure for new normative documents

Every new normative document should include:

1. `# Title` using the product or subsystem name.
2. Metadata block with version, status, scope/module, owner when known, and last reviewed date.
3. A short purpose statement.
4. Normative dependencies such as ADRs, state machines, or security policies.
5. Functional requirements or behavioral rules.
6. Non-functional, accessibility, security, privacy, and analytics considerations where relevant.
7. Acceptance criteria or links to the acceptance criteria document.
8. Open questions only when they are clearly labeled and owned.

## Writing rules

- Prefer relative Markdown links over absolute machine-specific paths.
- Use descriptive link text instead of “click here”.
- Keep headings hierarchical and avoid skipping heading levels.
- Use tables for matrices and checklists, but keep prose for rationale.
- State whether AI behavior is advisory, user-confirmed, or system-enforced.
- Document failure modes for sync, export, authentication, provider errors, and destructive actions.
- Use inclusive, plain language and define project-specific terms in the glossary.

## Review checklist

Before merging documentation changes, verify that:

- [ ] Changed behavior is reflected in relevant acceptance criteria.
- [ ] Architecture or storage changes reference the relevant ADR.
- [ ] Security, privacy, accessibility, and analytics impacts are explicitly considered.
- [ ] New or renamed concepts are added to the glossary.
- [ ] Links are relative and resolvable from the repository.
- [ ] The documentation hub still points to the canonical document.

## Documentation debt policy

Documentation debt is allowed only when it is visible. If a document cannot be completed in the current change, add an explicit `Open questions` or `Documentation debt` section with an owner, impact, and expected resolution path.
