import React, { useState } from "react";
import Board from "frontend/components/Board";
import TileRack from "frontend/components/TileRack";
import ExchangeView from "frontend/components/ExchangeView";

import { Link } from "react-router-dom";

const PlayArea = ({
  boardValues,
  tempBoardValues,
  rackValues,
  lastMoveInfo,
  gameFlowData,
  handleBoardSet,
  handleRackSet,
  postTilePlacement,
  postPass,
  postExchange
}) => {
  const [exchanging, setExchanging] = useState(false);

  if (exchanging) {
    return (
      <ExchangeView
        rackValues={rackValues}
        postExchange={postExchange}
        cancel={() => setExchanging(false)}
      />
    );
  }

  const renderGameOver = () => (
    <div className="gameover-message">
      <h1>Game Over. {gameFlowData.your_win ? "You Win!" : "They Win!"}</h1>
    </div>
  );

  return (
    <div className="play-area">
      <div className="play-area-box">
        <Link to ={`/games/${gameFlowData.id}/move_history`} >
          <button>
            Show Move History
          </button>
        </Link>
        <Link to ={`/games/${gameFlowData.id}/tile_distribution`} >
          <button>
            Show Tile Distribution
          </button>
        </Link>
      </div>
      <div className="play-area-box">
        {
          gameFlowData.complete ? renderGameOver() : <div/>
        }
        <Board
          boardValues={boardValues}
          tempBoardValues={tempBoardValues}
          lastMoveInfo={lastMoveInfo}
          handleBoardSet={handleBoardSet}
        />
        <TileRack rackValues={rackValues} handleRackSet={handleRackSet} />
        <button
          className="play-btn"
          onClick={postTilePlacement}
          disabled={!gameFlowData.your_turn || gameFlowData.complete}
        >
          PLAY!
        </button>
      </div>
      <div className="play-area-box">
        <button
          onClick={postPass}
          disabled={!gameFlowData.your_turn || gameFlowData.complete}
        >
          Pass
        </button>
        <button
          onClick={() => setExchanging(true)}
          disabled={
            !gameFlowData.your_turn ||
            !gameFlowData.allow_swap ||
            gameFlowData.complete
          }
        >
          Exchange tiles
        </button>
      </div>
    </div>
  );
};

export default PlayArea;
