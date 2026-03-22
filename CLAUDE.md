# King of 20

## Keeping This File Current
When making significant changes to the codebase — especially AI logic, game mechanics, or architecture — update the relevant sections of this file. This file is the primary context source for new Claude sessions.

## Game Rules

### Goal
Players build interlocking math expressions on the board. Each turn's score is `|20 - expression_result|`. Lowest cumulative score wins.

### Tiles
- Number tiles: 1–9 (single digits only — adjacent numbers never combine into multi-digit values)
- Operation tiles: + × − ÷
- Digital tile IDs: 1–9 = numbers, 10=+, 11=×, 12=−, 13=÷
- Rack size: 7 tiles (physical game uses 5; digital uses 7)

### Expression Rules
- Expressions are read **strictly left to right or top to bottom** — **no order of operations**
  - `4 + 9 × 2 = 26` (not 22)
- Expressions must be **linear**: one contiguous row or one contiguous column, never diagonal
- Valid structure alternates numbers and operators: `num op num op num ...`
- **No fractions** — a division that would produce a non-integer is not a legal move
- **Extraneous operators rule**: board tiles adjacent to a new expression that don't syntactically participate in it are simply ignored — they do not invalidate the move
  - Example: placing `3` to form `3 + 2 × 4 = 20` is legal even if a stray `/` from another expression sits next to it on the board

### Placement Rules
- All tiles placed in a single turn must lie in **one row or one column**
- **Only one expression may be formed per turn** — placing tiles that would create two separate valid expressions is illegal
- After the first move, every play must incorporate at least one tile already on the board (extending an existing expression or crossing one perpendicularly)
- First move: must cover at least one designated starting space; must use exactly 3 tiles (1 operator + 2 numbers)
- Tiles already placed on the board cannot be moved or replaced

### Scoring
- Score per turn: `|20 - expression_result|` (0 = perfect)
- When a player extends an existing expression, their score is based on the **entire resulting expression**
- Swap or pass penalty: **10 points**

### Turn Options
- **Place tiles**: play 1–3 tiles to form or extend an expression
- **Swap**: return any tiles to the bag and draw replacements; 10-point penalty
- **Pass**: skip the turn; 10-point penalty

### End Game
- When the bag empties, each player gets **2 more turns** (tracked as `end_round_one` → `end_round_two` → `complete`)
- The game may end with tiles remaining on racks
- Player with the lowest total score wins

### Digital-Specific
- The human player is always `initiator`; AI or opponent is `opponent`
- Game stages: `in_play` → `end_round_one` → `end_round_two` → `complete` (also `initiator_forfit` / `opponent_forfit`)

## Game Mechanics Reference
- Board: 12×12 grid
- Rack size: 7 tiles
- Move scoring: `|20 - expression_result|` (lower = better, 0 = perfect)
- Swap penalty: 10 points (returns tiles to bag, draws new ones)
- Turn options: place tiles, swap, or pass
- The human player is always `initiator`; AI or opponent is `opponent`
- Game stages: `in_play` → `end_round_one` → `end_round_two` → `complete` (also `initiator_forfit` / `opponent_forfit`)

## AI System (`app/services/ai/`)
- `BaseAi` — shared logic: `calculate_move_score`, `best_swap_tiles`, `can_swap?`, `execute_swap`, superset filtering, shared constants (`SWAP_THRESHOLD=10`, `MIN_SWAP_TILES=2`, `MIN_BAG_SIZE_FOR_SWAP=10`, `LEAVE_NO_MOVES_PENALTY=20`)
- `MoveFinder` — finds all valid moves for a given board/rack
- `EasyAi` — immediate-score-only selection with quality floor (`QUALITY_FLOOR=5`) and rubber-banding K; scores all post-filter moves once with `calculate_move_score`, applies floor, picks randomly from top K (`K_LOSING=1`, `K_NEUTRAL=3`, `K_WINNING=5`, `RUBBER_BAND_THRESHOLD=10`)
- `HardAi` — immediate-score-only, greedy and deterministic: always plays the move with the lowest `calculate_move_score`
- **Move scoring**: `calculate_move_score` = `|20 - expression_result|` (lower = better, 0 = perfect); no leave evaluation
- **Swap decision** (both AIs): swap when `SWAP_THRESHOLD (10) < best immediate score` from post-filter moves
- **Swap tile selection**: keeps tiles participating in the best `number op number` combo; discards the rest
- AI runs as a background job via Sidekiq (`AiMoveJob`); ~0.1-0.2s response time

## Cleanup Rules
- After moving or refactoring code, delete any files/components that are no longer used
- Remove unused imports
- Don't leave orphaned files behind

## Style Preferences
- Avoid box-shadow by default. It can be used when it clearly enhances the design, but should not be the go-to choice.

## Future Tech Debt
- **Bundler upgrade**: Currently using Webpacker 5 / Webpack 4 which doesn't transpile node_modules by default. Modern packages ship ES2020+ syntax. Had to add `@babel/plugin-proposal-nullish-coalescing-operator` to support `react-dnd-multi-backend`. Consider migrating to Vite or Webpack 5 for better modern package support.
- **ActionCable broadcast cleanup**: Remove `after_save :broadcast` callback from `Game` model and broadcast explicitly where needed (e.g., in `MoveManager` after move creation, in `AiMoveJob` after AI move). Callbacks don't work reliably across process boundaries (Sidekiq) and mixing implicit callbacks with explicit broadcasts is confusing.
- **Sidekiq Web UI**: Add Sidekiq web dashboard at `/sidekiq` protected by admin authentication. Useful for monitoring job queues, retries, and failures.
- **Email verification**: Consider adding Devise `:confirmable` to verify email addresses. Currently emails are optional and unverified, which means a troll could register someone else's email before the real owner. With confirmable, unverified emails can't be used for password reset.
