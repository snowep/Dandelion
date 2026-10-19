# U5 — catalog lookup and library flows

## Scope

Keep manual entry primary and fully usable offline. Title/ISBN lookup is optional and should reduce typing without hijacking existing personal data.

## Required changes

1. Trace each lookup entry point from Library add/edit, ISBN form and Discover. Remove duplicate/dead paths only after checking imports and route references.
2. Use mocked network responses for success, no results, rate limit, malformed response, missing cover and timeout. No test should require the real provider.
3. Preview catalog results and allow field selection. Do not overwrite rating, reading progress, personal notes, purchase/lending data or user-chosen cover without consent.
4. Normalize ISBN and title/author matching through the same tested repository policy used by import. Warn on duplicate ISBN/title while allowing deliberate same-title/different-author items.
5. Ensure a failed lookup always returns the user to manual add/edit without losing entered form data. Add/edit should be available without internet and on a fresh install.
6. Test saved catalogue data, cover key, provider URL/ID, and retry/error/empty/loading UI states.

## Acceptance

Library CRUD works offline; lookup is optional, tested with mocks, preserves user-owned fields and never creates broken cover references.
