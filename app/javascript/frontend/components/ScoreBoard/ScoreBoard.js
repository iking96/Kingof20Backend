import React, { useEffect, useState, useRef } from "react";

const ScoreBoard = ({
  yourTurn,
  initiatorUsername,
  opponentUsername,
  playerScore,
  opponentScore
}) => {
  const scoreboard_lt_ref = useRef();
  const scoreboard_rt_ref = useRef();

  useEffect(() => {
    const scoreboard_lt = scoreboard_lt_ref.current;
    const scoreboard_rt = scoreboard_rt_ref.current;

    if (yourTurn) {
      scoreboard_lt.classList.add("current");
      scoreboard_rt.classList.remove("current");
    } else {
      scoreboard_lt.classList.remove("current");
      scoreboard_rt.classList.add("current");
    }
  }, [yourTurn]);

  return (
    <div className="scoreboard">
      <div ref={scoreboard_lt_ref} className="scoreboard-lt">
        <h1>{initiatorUsername}</h1>
        <h2>{playerScore}</h2>
      </div>
      <div ref={scoreboard_rt_ref} className="scoreboard-rt">
        <h1>{opponentUsername ? opponentUsername : "Searching..."}</h1>
        <h2>{opponentScore}</h2>
      </div>
    </div>
  );
};

export default React.memo(ScoreBoard);
