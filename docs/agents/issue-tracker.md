# Issue tracker: GitHub

Issues and specs for this repository live in GitHub Issues at `trungtin252/GreenLedgerExchange`. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`.
- **Apply or remove labels**: `gh issue edit <number> --add-label "..."` or `gh issue edit <number> --remove-label "..."`.
- **Close an issue**: `gh issue close <number> --comment "..."`.

Infer the repository from `git remote -v`; `gh` does this automatically when run inside this clone.

## Pull requests as a triage surface

**PRs as a request surface: no.** Set this to `yes` if this repository later treats external pull requests as feature requests.

When set to `yes`, pull requests run through the same labels and states as issues, using the `gh pr` equivalents:

- **Read a pull request**: `gh pr view <number> --comments` and `gh pr diff <number>`.
- **List external pull requests for triage**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`, then keep only `authorAssociation` values `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR`, or `NONE`.
- **Comment, label, or close**: use `gh pr comment`, `gh pr edit --add-label` or `--remove-label`, and `gh pr close`.

GitHub shares one number space across issues and pull requests. Resolve a bare `#<number>` with `gh pr view <number>` first, then fall back to `gh issue view <number>`.

## Skill operations

When a skill says "publish to the issue tracker", create a GitHub issue.

When a skill says "fetch the relevant ticket", run `gh issue view <number> --comments`.

## Wayfinding operations

The `wayfinder` skill uses one issue as a map and links child issues as tickets.

- **Map**: create one issue labelled `wayfinder:map`, containing the Notes, Decisions-so-far, and Fog sections.
- **Child ticket**: link a child with GitHub sub-issues and apply a `wayfinder:<type>` label (`research`, `prototype`, `grilling`, or `task`). If sub-issues are unavailable, add the child to the map task list and put `Part of #<map>` at the top of the child body.
- **Blocking**: use native GitHub issue dependencies. If dependencies are unavailable, put `Blocked by: #<number>` at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children, then drop tickets with an open blocker or an assignee. The first ticket in map order wins.
- **Claim**: run `gh issue edit <number> --add-assignee @me`; this is the session's first write.
- **Resolve**: comment with the answer, close the ticket, and append a concise context pointer to the map's Decisions-so-far section.
