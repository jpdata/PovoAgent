# Change Request

> Template for requesting a change to an existing project: new feature, modification, or refactor.
> Fill this document during the `change-intake` conversation.

## Metadata

| Field | Value |
|---|---|
| ID | CR-<NNN> |
| Project | <project name> |
| Type | Feature / Modification / Refactor |
| Priority | Critical / High / Medium / Low |
| Architecture | Clean Architecture / Vertical Slice Architecture |
| Author | <author> |
| Date | <date> |

## Motivation

<Why this change is needed. What problem it solves or value it adds. One paragraph.>

## Current State

<What currently exists. Reference existing specs, features, or behavior. Be concrete.>

## Expected State

<Concrete description of what should exist after the change. Include user-facing and system-facing outcomes.>

## Scope

| Aspect | Detail |
|---|---|
| Affected Features | <list of feature names> |
| Affected Layers (CA) | <Presentation / Application / Domain / Infrastructure> |
| Affected Slices (VSA) | <list of slice names> |
| Known Affected Files | <list of files or modules> |
| Cross-Slice / Cross-Layer Dependencies | <contracts or interfaces affected> |

## Architecture Impact

| Aspect | Detail |
|---|---|
| Contracts Changed | <Yes / No. If yes, which ones?> |
| New Dependencies | <List of new external or internal dependencies> |
| Breaking Changes | <Yes / No. If yes, describe.> |
| New API Endpoints | <If applicable, list HTTP method + path> |
| New Routes or Pages | <If applicable, list new routes> |

## Specification Reference

<If this change needs a new spec document, note the SPEC ID here. If it modifies an existing spec, list the spec and changed sections.>

## Testing

| Aspect | Detail |
|---|---|
| Existing Tests Covering This Area | <list of test files> |
| New Tests Required | <list of test scenarios> |
| Regression Risk | <High / Medium / Low — why?> |

## Rollback

<How to undo this change if it causes problems. Be specific: revert commit, rollback migration, redeploy previous version, etc.>

## Workflow

| # | Phase | Skill | Output |
|---|---|---|---|
| 1 | <phase> | <skill> | <output> |
| 2 | <phase> | <skill> | <output> |
| ... | ... | ... | ... |

## Approval

- [ ] Change request reviewed and approved by user
- [ ] Specification updated (if applicable)
- [ ] Design updated (if applicable)
