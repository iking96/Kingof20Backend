import React, { useState } from "react";
import "./HowToPlay.scss";
import { swapPassPenalty } from "frontend/utils/constants.js";

const HtpTile = ({ label }) => (
  <div className="htp-tile">{label}</div>
);

const CardGoal = () => (
  <>
    <p className="htp-goal-intro">
      Build math formulas on the board.<br />
      Get as close to <strong>20</strong> as possible.<br />
      Lowest score wins.
    </p>
    <div className="htp-formula-container">
      <HtpTile label="8" />
      <HtpTile label="+" />
      <HtpTile label="4" />
      <HtpTile label="×" />
      <HtpTile label="2" />
      <span className="htp-tile-equals">=</span>
      <div className="htp-tile-result">24</div>
      <span className="htp-tile-equals">→ score: |20−24| = <strong>4</strong></span>
    </div>
    <p className="htp-formula-caption">Lower score is better. Zero is perfect.</p>
  </>
);

const CardBoard = () => (
  <>
    <div className="htp-board-placeholder">
      📷 Board screenshot coming soon
    </div>
    <p className="htp-board-caption">
      12×12 grid. Your first move must include at least one tile
      on a <strong>highlighted starting square</strong>. First move uses exactly 3 tiles.
    </p>
  </>
);

const CardYourTurn = () => (
  <div className="htp-turn-options">
    <div className="htp-turn-option">
      <div className="htp-turn-title">Place</div>
      <div className="htp-turn-desc">Play 1–3 tiles to form or extend a formula.</div>
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
);

const CardPlacement = () => (
  <>
    <div className="htp-placement-examples">
      <div className="htp-placement-example valid">
        <div className="htp-example-label">✅ Valid — extend existing</div>
        <div className="htp-tile-row">
          <HtpTile label="4" />
          <HtpTile label="+" />
          <HtpTile label="7" />
          <HtpTile label="×" />
          <HtpTile label="2" />
        </div>
      </div>
      <div className="htp-placement-example invalid">
        <div className="htp-example-label">❌ Invalid — two formulas</div>
        <div className="htp-tile-row">
          <HtpTile label="3" />
          <HtpTile label="+" />
          <HtpTile label="5" />
        </div>
        <div className="htp-invalid-note">
          + isolated formula nearby
        </div>
      </div>
    </div>
    <ul className="htp-rules-list">
      <li>All tiles in one turn must be in one row or column</li>
      <li>Every play after the first must touch a tile already on the board</li>
      <li>Only one formula may be formed per turn</li>
      <li>No diagonal play</li>
      <li>No fractions — division must produce a whole number</li>
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
      <HtpTile label="+" />
      <HtpTile label="9" />
      <HtpTile label="×" />
      <HtpTile label="2" />
      <span className="htp-tile-equals">=</span>
      <div className="htp-tile-result">26</div>
      <span className="htp-tile-equals">→ |20−26| = <strong>6 pts</strong></span>
    </div>
    <div className="htp-score-callout">
      🎯 A formula that equals exactly <strong>20</strong> scores <strong>0 points</strong> — perfect!
    </div>
  </>
);

const CardTiles = () => (
  <>
    <div className="htp-tile-table-wrap">
      <table className="htp-tile-table">
        <thead>
          <tr><th>Number</th><th>Count</th></tr>
        </thead>
        <tbody>
          {[[1,4],[2,2],[3,4],[4,6],[5,4],[6,4],[7,2],[8,5],[9,2]].map(([n,c]) => (
            <tr key={n}><td>{n}</td><td>{c}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="htp-tile-table">
        <thead>
          <tr><th>Operator</th><th>Count</th></tr>
        </thead>
        <tbody>
          <tr><td>+</td><td>5</td></tr>
          <tr><td>×</td><td>8</td></tr>
          <tr><td>−</td><td>8</td></tr>
          <tr><td>÷</td><td>4</td></tr>
        </tbody>
      </table>
    </div>
    <p className="htp-tile-table-note">58 tiles total in the bag</p>
  </>
);

const CARD_COMPONENTS = [
  { title: "The Goal",         Component: CardGoal },
  { title: "The Board",        Component: CardBoard },
  { title: "Your Turn",        Component: CardYourTurn },
  { title: "Placement Rules",  Component: CardPlacement },
  { title: "Scoring",          Component: CardScoring },
  { title: "Tile Reference",   Component: CardTiles },
];

const HowToPlay = () => {
  const [current, setCurrent] = useState(0);
  const { title, Component } = CARD_COMPONENTS[current];

  const prev = () => setCurrent(i => Math.max(0, i - 1));
  const next = () => {
    setCurrent(i =>
      i < CARD_COMPONENTS.length - 1 ? i + 1 : 0
    );
  };

  return (
    <div className="how-to-play">
      <div className="htp-card">
        <div className="htp-card-header">
          <div className="htp-step-label">Step {current + 1} of {CARD_COMPONENTS.length}</div>
          <h2 className="htp-card-title">{title}</h2>
        </div>

        <div className="htp-card-body">
          <Component />
        </div>

        <div className="htp-card-footer">
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
      </div>
    </div>
  );
};

export default HowToPlay;
