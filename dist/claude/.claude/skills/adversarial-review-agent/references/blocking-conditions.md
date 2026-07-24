# Blocking Conditions

The workflows must stop or ask a focused question when a hard blocker is present.

| Blocker | What to inspect | What to report | Stop or proceed | User action that resolves it | Guidance shape |
|---|---|---|---|---|---|
| Missing or unreadable required input | Inputs, file paths, repository discovery result | Which required value is missing or unreadable | Stop | Provide the missing file, path, or inline story text | Concise English error with the missing field |
| Missing required Superpowers skill | Skill lookup result | The exact missing skill name(s) | Stop | Install the required skill(s) | One concise error listing all missing names |
| Story and notes contradict each other materially | Story text and notes text | The conflicting statements | Stop | Clarify which source governs | English explanation of the conflict |
| Design and implementation plan contradict each other | Spec and plan content | The specific mismatch | Stop | Revise the plan or spec | English explanation of the contradiction |
| Baseline tests fail before implementation | Baseline test command output | The failing tests and failure details | Stop | Fix the baseline or confirm a new starting point | English blocker report with failing commands |
| A breaking change is required but not approved | Spec, plan, and requested behavior | The breaking change that lacks approval | Stop | Approve the breaking change explicitly | English request for approval |
| An architectural decision is required but absent from the approved design | Spec content | The missing decision and why it matters | Stop | Add the decision to the approved design | English request for a design decision |
| The current branch or worktree contains unsafe unrelated changes | Git status and diff | The unrelated changes that create risk | Stop | Clean or isolate the unrelated changes | English safety warning |
| Required external access is unavailable | Tool availability and connection state | Which external access is missing | Stop or proceed only with explicit assumption | Restore access or approve a fallback | English access warning |
| The plan references files or interfaces that do not exist and cannot be derived | Plan references and repository files | The unresolved file or interface reference | Stop | Add the missing file or update the plan | English missing-reference error |
| A task is marked complete but verification evidence contradicts it | Progress artifact and test output | The mismatch between the checkbox and evidence | Stop | Re-run the task and correct the progress record | English evidence conflict report |

