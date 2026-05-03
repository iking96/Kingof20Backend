import React, { useState } from "react";
import "./HowToPlay.scss";
import { swapPassPenalty } from "frontend/utils/constants.js";
import boardScreenshot from "frontend/assets/how-to-play/board-screenshot.png";

const HtpTile = ({ label, variant }) => (
  <div className={`htp-tile${variant ? ` htp-tile-${variant}` : ""}`}>{label}</div>
);

const CardGoal = () => (
  <>
    <p className="htp-goal-intro">
      Build math formulas on the board.<br />
      Get as close to <strong>20</strong> as possible.<br />
      Lowest score wins.
    </p>
    <div className="htp-formula-container">
      <HtpTile label="5" />
      <HtpTile label="Times" />
      <HtpTile label="4" />
      <span className="htp-tile-equals">= <em>20</em></span>
    </div>
    <p className="htp-formula-caption">Lower score is better. Zero is perfect.</p>
  </>
);

const CardBoard = () => (
  <>
    <img
      src={boardScreenshot}
      alt="King of 20 game board"
      className="htp-board-screenshot"
    />
    <p className="htp-board-caption">
      12×12 grid. Your first move must include at least one tile on
      a <strong>highlighted starting square</strong> near the center of the board.
      First move uses exactly 3 tiles.
    </p>
  </>
);

const CardYourTurn = () => (
  <>
    <p className="htp-rack-intro">
      You have <strong>7 tiles</strong> on your rack. After placing,
      your tiles will be replenished from the bag.
    </p>
    <div className="htp-rack-row">
      {Array(7).fill(null).map((_, i) => (
        <HtpTile key={i} label="?" />
      ))}
    </div>
    <div className="htp-turn-options">
      <div className="htp-turn-option">
        <div className="htp-turn-title">Place</div>
        <div className="htp-turn-desc">Play 1–3 tiles to form or extend a valid formula.</div>
      </div>
      <div className="htp-turn-option">
        <div className="htp-turn-title">Swap</div>
        <div className="htp-turn-desc">Return tiles to the bag and draw new ones.</div>
        <div className="htp-penalty-badge">−{swapPassPenalty} pts</div>
      </div>
      <div className="htp-turn-option">
        <div className="htp-turn-title">Pass</div>
        <div className="htp-turn-desc">Skip your turn.</div>
        <div className="htp-penalty-badge">−{swapPassPenalty} pts</div>
      </div>
    </div>
  </>
);

const CardPlacement = () => (
  <>
    <div className="htp-placement-legend">
      <HtpTile label="4" variant="board" />
      <span>= on board</span>
      <HtpTile label="Times" variant="new" />
      <span>= your tile</span>
    </div>

    <div className="htp-placement-examples">
      <div className="htp-placement-example valid">
        <div className="htp-example-label">✅ Valid — extend existing</div>
        <div className="htp-tile-row">
          <HtpTile label="4" variant="board" />
          <HtpTile label="Plus" variant="board" />
          <HtpTile label="7" variant="board" />
          <HtpTile label="Times" variant="new" />
          <HtpTile label="2" variant="new" />
        </div>
        <div className="htp-example-caption">Extending a formula already on the board.</div>
      </div>

      <div className="htp-placement-example invalid">
        <div className="htp-example-label">❌ Invalid — two formulas</div>
        <div className="htp-tile-row">
          <HtpTile label="4" variant="board" />
          <HtpTile label="Plus" variant="board" />
          <HtpTile label="7" variant="board" />
          <span className="htp-tile-gap">···</span>
          <HtpTile label="3" variant="new" />
          <HtpTile label="Plus" variant="new" />
          <HtpTile label="5" variant="new" />
        </div>
        <div className="htp-example-caption">A gap between tiles creates two separate formulas.</div>
      </div>
    </div>

    <div className="htp-placement-example valid">
      <div className="htp-example-label">✅ Valid — dangling operator ignored</div>
      <div className="htp-tile-row">
        <HtpTile label="4" variant="board" />
        <HtpTile label="Plus" variant="board" />
        <HtpTile label="7" variant="board" />
        <HtpTile label="Times" variant="new" />
        <HtpTile label="2" variant="new" />
        <div className="htp-tile-ignored-wrap">
          <HtpTile label="Over" variant="ignored" />
          <div className="htp-tile-ignored-label">ignored</div>
        </div>
      </div>
      <div className="htp-example-caption">
        The "Over" tile was placed by a crossing formula — it's ignored. Your formula: 4 + 7 × 2 = 22.
      </div>
    </div>

    <ul className="htp-rules-list">
      <li>All tiles in one turn must be in one row or column</li>
      <li>No diagonal play</li>
      <li>No fractions — division must produce a whole number</li>
      <li>Formulas evaluate left to right — no order of operations</li>
    </ul>
  </>
);

const CardScoring = () => (
  <>
    <p className="htp-scoring-rule">
      Score = <strong>|20 − result|</strong>. Lower is better. Zero is perfect.
    </p>
    <p className="htp-scoring-rule htp-scoring-note">
      No order of operations — evaluate strictly <strong>left to right</strong>.
    </p>
    <div className="htp-formula-container">
      <HtpTile label="4" />
      <HtpTile label="Plus" />
      <HtpTile label="9" />
      <HtpTile label="Times" />
      <HtpTile label="2" />
      <span className="htp-tile-equals">=</span>
      <div className="htp-tile-result">26</div>
      <span className="htp-tile-equals">→ |20−26| = <strong>6 pts</strong></span>
    </div>
    <div className="htp-score-callout">
      🎯 A formula that equals exactly <strong>20</strong> scores <strong>0 points</strong> — perfect!
    </div>
    <p className="htp-scoring-accumulate">
      Scores accumulate each turn — lowest total at the end of the game wins.
    </p>
  </>
);

const TILE_NUMBERS = [[1,4],[2,2],[3,4],[4,6],[5,4],[6,4],[7,2],[8,5],[9,2]];
const TILE_OPERATORS = [["Plus",5],["Times",8],["Minus",8],["Over",4]];
const RARE_TILES = new Set([2, 7, 9]);

const CardTileRef = () => (
  <>
    <p className="htp-tile-table-note">58 tiles total in the bag</p>
    <p className="htp-tile-section-label">Numbers</p>
    <div className="htp-tile-grid">
      {TILE_NUMBERS.map(([n, c]) => (
        <div key={n} className="htp-tile-grid-item">
          <HtpTile label={String(n)} />
          <div className="htp-tile-count">×{c}</div>
          {RARE_TILES.has(n) && <div className="htp-tile-rare">rare</div>}
        </div>
      ))}
    </div>
    <p className="htp-tile-section-label">Operators</p>
    <div className="htp-tile-grid">
      {TILE_OPERATORS.map(([op, c]) => (
        <div key={op} className="htp-tile-grid-item">
          <HtpTile label={op} />
          <div className="htp-tile-count">×{c}</div>
        </div>
      ))}
    </div>
  </>
);

const CardEndGame = () => (
  <>
    <ul className="htp-rules-list">
      <li>When the bag is empty, each player gets <strong>2 more turns</strong>.</li>
      <li>The game may end with tiles still on your rack.</li>
    </ul>
    <div className="htp-score-callout">
      🏆 The player with the <strong>lowest total score</strong> wins.
    </div>
  </>
);

const CARD_COMPONENTS = [
  { title: "The Goal",        Component: CardGoal },
  { title: "The Board",       Component: CardBoard },
  { title: "Your Turn",       Component: CardYourTurn },
  { title: "Placement Rules", Component: CardPlacement },
  { title: "Scoring",         Component: CardScoring },
  { title: "Tile Reference",  Component: CardTileRef },
  { title: "End Game",        Component: CardEndGame },
];

const HowToPlay = () => {
  const [current, setCurrent] = useState(0);
  const { title, Component } = CARD_COMPONENTS[current];

  const prev = () => setCurrent(i => Math.max(0, i - 1));
  const next = () => setCurrent(i =>
    i < CARD_COMPONENTS.length - 1 ? i + 1 : 0
  );

  return (
    <div className="how-to-play">
      <div className="htp-card">
        <div className="htp-card-header">
          <div className="htp-header-nav">
            <button
              className={`htp-nav-btn htp-prev${current === 0 ? " htp-hidden" : ""}`}
              onClick={prev}
            >
              ← Back
            </button>
            <div className="htp-dots">
              {CARD_COMPONENTS.map((_, i) => (
                <div
                  key={i}
                  className={`htp-dot${i === current ? " active" : ""}`}
                />
              ))}
            </div>
            <button className="htp-nav-btn htp-next" onClick={next}>
              {current === CARD_COMPONENTS.length - 1 ? "Done ✓" : "Next →"}
            </button>
          </div>
          <div className="htp-step-label">Step {current + 1} of {CARD_COMPONENTS.length}</div>
          <h2 className="htp-card-title">{title}</h2>
        </div>

        <div className="htp-card-body">
          <Component />
        </div>
      </div>
    </div>
  );
};

export default HowToPlay;
