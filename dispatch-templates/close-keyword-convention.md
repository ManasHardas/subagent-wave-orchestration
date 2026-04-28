# Close-keyword convention (PERMANENT)

## Body (paste verbatim into dispatch briefs)

> If your PR closes one issue: PR body's first line is `Closes #<N>` on its own line.
>
> If your PR closes multiple issues (bundled-PR pattern): list each issue on its OWN `Closes #<N>` line. GitHub's auto-close keyword only matches the `Closes #N` prefix pattern PER LINE — `Closes #40 + #41` will close #40 but leave #41 stale-open.

## Why permanent

Real-project history: bundled PRs using comma-separated or plus-separated `Closes` keywords (`Closes #40 + #41`, `Closes #40, #41`) have GitHub auto-close ONLY the first issue. The second issue stays open until manually closed at a future session opener. Wasted opener time + stale-issue-list pollution.

After encoding this clause as one-line-per-Closes, bundled PRs reliably auto-close all referenced issues on merge.

## Examples

### Single-issue PR

```
Closes #142

## Summary
- ...
```

### Bundled-PR (multiple issues)

```
Closes #155
Closes #156

## Summary
- ...
```

WRONG — only #155 closes:

```
Closes #155 + #156

## Summary
...
```

WRONG — only #155 closes:

```
Closes #155, #156

## Summary
...
```

## Tracking in PR body

Build agents confirm in the "Dispatch-template clauses honored" section:

```markdown
- **Close-keyword convention:** ✅ `Closes #<N>` first line of PR body
  (or N separate lines for bundled PRs).
```
