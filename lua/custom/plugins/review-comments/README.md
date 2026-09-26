# Review comments

Add comments to files in Neovim and collect them in a review session. Open a file before adding a comment. Line and range comments have a `◆` sign in the gutter. File comments have a `◇` sign on the first line. Both show a preview beside the code.

## Add and manage comments

| Action | Keys | Command |
| --- | --- | --- |
| Comment on the current line | `<leader>rc` | `:ReviewCommentAdd` |
| Comment on a visual selection | Select lines, then `<leader>rc` | `:'<,'>ReviewCommentAdd` |
| Comment on the current file | `<leader>rC` | `:ReviewCommentAdd file` |
| Edit a comment at the cursor | `<leader>re` | `:ReviewCommentEdit` |
| Delete a comment at the cursor | `<leader>rd` | `:ReviewCommentDelete` |
| Browse comments in the session | `<leader>rl` | `:ReviewCommentList` |
| Browse files with comments | `<leader>ro` | `:ReviewCommentOverview` |
| Jump between comments in this file | `]r` / `[r` | `:ReviewCommentNext` / `:ReviewCommentPrevious` |
| Hide or show inline text | `<leader>rt` | `:ReviewCommentToggle` |

Write the comment in the popup, then press `Ctrl-S` in normal or insert mode to save. Press `q` in normal mode to cancel. For a comment on the whole file, place the cursor anywhere in that file to edit, show, or delete it. If several comments match, choose one from the menu. Use `:ReviewCommentShow` to read the full comment.

## Sessions and output

Comments are saved automatically to the active session. Sessions let you keep separate sets of comments.

| Action | Keys | Command |
| --- | --- | --- |
| Create or join a session | `<leader>rj` | `:ReviewCommentJoinSession` |
| Show the active session | `<leader>rs` | `:ReviewCommentCurrentSession` |
| Browse saved sessions and their comments | `<leader>rh` | `:ReviewCommentHistory` |
| Copy the active review as Markdown to the system clipboard | `<leader>ry` | `:ReviewCommentCopy` |
| Export the active review to a new file | `<leader>rx` | `:ReviewCommentExport path.md` |

When joining a session, choose whether to move the current comments or leave them in the previous session. Export will not overwrite an existing file. Use `:ReviewCommentStorePath` to see and copy the storage directory.

To remove comments, use `:ReviewCommentClearFile`, `:ReviewCommentClearSession`, or `:ReviewCommentClearStore`. Each asks for confirmation. Clearing the store deletes saved sessions across all projects.
