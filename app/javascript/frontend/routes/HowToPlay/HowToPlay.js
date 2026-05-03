import React, { useState, useEffect } from "react";
import "./HowToPlay.scss";
import { swapPassPenalty } from "frontend/utils/constants.js";
import boardScreenshot from "frontend/assets/how-to-play/board-screenshot.png";

const HtpTile = ({ label, variant }) => (
  <div className={`htp-tile${variant ? ` htp-tile-${variant}` : ""}${label.length > 1 ? " htp-tile-word" : ""}`}>{label}</div>
);

const CardGoal = () => (
  <>
    <p className="htp-goal-intro">
      Build math expressions on the board.<br />
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
      The board is a 12×12 grid. Your first move must include at least one tile on
      a <strong>grey starting square</strong>, and use exactly 3 tiles.
    </p>
  </>
);

const CardYourTurn = () => (
  <>
    <p className="htp-rack-intro">
      You have <strong>7 tiles</strong> on your rack. After placing,
      your tiles will be replenished from the bag.
    </p>

    <p className="htp-rack-intro">On your turn you can:</p>
    <div className="htp-turn-options">
      <div className="htp-turn-option">
        <div className="htp-turn-title">Place</div>
        <div className="htp-turn-desc">Play 1–3 tiles to form or extend a valid expression.</div>
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
      <HtpTile label="Times" variant="new" />
      <span>= tile you are placing this turn</span>
    </div>

    <div className="htp-placement-examples">
      <div className="htp-placement-example valid">
        <div className="htp-example-label">Extend an existing expression</div>
        <div className="htp-tile-row">
          <HtpTile label="4" />
          <HtpTile label="Plus" />
          <HtpTile label="7" />
          <HtpTile label="Times" variant="new" />
          <HtpTile label="2" variant="new" />
        </div>
        <div className="htp-example-or"><em>or</em></div>
        <div className="htp-tile-row">
          <HtpTile label="2" variant="new" />
          <HtpTile label="Times" variant="new" />
          <HtpTile label="4" />
          <HtpTile label="Plus" />
          <HtpTile label="7" />
        </div>
        <div className="htp-example-caption">Play your tiles at either end of an expression already on the board.</div>
      </div>

      <div className="htp-placement-example valid">
        <div className="htp-example-label">A trailing operator with nothing after it is ignored</div>
        <div className="htp-tile-row">
          <HtpTile label="4" />
          <HtpTile label="Plus" />
          <HtpTile label="7" />
          <HtpTile label="Times" variant="new" />
          <HtpTile label="2" variant="new" />
          <HtpTile label="Minus" />
        </div>
        <div className="htp-example-caption">
          The <em>Minus</em> tile has no number following it, so your expression stops at "4 Plus 7 Times 2". If a number followed it, <em>Minus</em> would be part of your expression.
        </div>
      </div>
    </div>

    <div className="htp-rules-list">
      <p>Only one expression can be made per turn</p>
      <p>All tiles in one turn must be in one row or column — no gaps</p>
      <p>Diagonal expressions are not permitted</p>
      <p>No fractions — division must produce a whole number</p>
    </div>
  </>
);

const CardScoring = () => (
  <>
    <p className="htp-scoring-rule">
      How far is your result from 20? That's your score.
    </p>
    <p className="htp-scoring-rule htp-scoring-note">
      No order of operations — evaluate strictly <strong>left to right</strong>.
    </p>
    <div className="htp-formula-container">
      <HtpTile label="3" />
      <HtpTile label="Plus" />
      <HtpTile label="9" />
      <HtpTile label="Times" />
      <HtpTile label="2" />
      <span className="htp-tile-equals">= <em>24</em> → |20−24| = <strong>4 pts</strong></span>
    </div>
    <div className="htp-score-callout">
      🎯 An expression that equals exactly <strong>20</strong> scores <strong>0 points</strong> — perfect!
    </div>
    <p className="htp-scoring-accumulate">
      Scores accumulate each turn — lowest total at the end of the game wins.
    </p>
  </>
);

const TILE_NUMBERS = [[1,4],[2,5],[3,4],[4,6],[5,5],[6,6],[7,5],[8,6],[9,4]];
const TILE_OPERATORS = [["Plus",8],["Times",8],["Minus",8],["Over",5]];
const CardTileRef = () => (
  <>
    <p className="htp-rack-intro">74 tiles total in the bag</p>
    <p className="htp-tile-section-label">Numbers</p>
    <div className="htp-tile-grid">
      {TILE_NUMBERS.map(([n, c]) => (
        <div key={n} className="htp-tile-grid-item">
          <HtpTile label={String(n)} />
          <div className="htp-tile-count">×{c}</div>
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

  useEffect(() => {
    const onKey = e => {
      if (e.key === "ArrowLeft") prev();
      if (e.key === "ArrowRight") next();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

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
