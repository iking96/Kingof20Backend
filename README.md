# King of 20

A turn-based math tile game where players compete to score as close to 20 as possible each round.

## How the Game Works

Players take turns placing tiles on a 12×12 board to form arithmetic expressions. Each turn, a player places one or more tiles from their 7-tile rack onto the board. The board is evaluated and scored as `|20 - expression_result|` — lower is better, 0 is perfect.

### Tiles

Tiles are integers 1–13:

| Value | Tile |
|-------|------|
| 1–9   | Numbers 1–9 |
| 10    | + (Plus) |
| 11    | × (Times) |
| 12    | − (Minus) |
| 13    | ÷ (Over) |

### Turn Options

- **Place tiles** — play tiles from rack onto the board to form/extend an expression
- **Swap** — return tiles to the bag and draw new ones (costs 10 points as penalty)
- **Pass** — skip your turn

### Game Structure

- Each player starts with 7 tiles drawn from a shared bag
- Rack is refilled from the bag after each turn
- Games progress through stages: `in_play` → `end_round_one` → `end_round_two` → `complete`
- Games can also end via forfeit
- Lower cumulative score wins

### Multiplayer & AI

- Games can be **player vs. player** (real-time via ActionCable) or **player vs. computer**
- AI supports Easy and Hard difficulty
- The human is always the `initiator`; the AI plays as `opponent`

## Tech Stack

- **Backend**: Ruby on Rails (API mode)
- **Frontend**: React (via Webpacker), served from the same Rails app
- **Real-time**: ActionCable (WebSockets)
- **Background jobs**: Sidekiq (AI moves run async)
- **Auth**: Devise

## Development Setup

```bash
bundle install
yarn install
bin/rails db:create db:migrate
bin/rails s
# In another terminal:
bin/webpack-dev-server
# Sidekiq (for AI jobs):
bundle exec sidekiq
```

## Running Tests

```bash
bundle exec rspec
# AI tests only:
bundle exec rspec spec/services/ai/
```
