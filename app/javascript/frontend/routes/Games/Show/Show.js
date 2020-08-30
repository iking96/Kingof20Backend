import React, { useEffect, useState, useRef } from "react";
import Board from "frontend/components/Board";
import TileRack from "frontend/components/TileRack";
import ScoreBoard from "frontend/components/ScoreBoard";
import ExchangeView from "frontend/components/ExchangeView";
import { DndProvider } from "react-dnd";
import Backend from "react-dnd-html5-backend";

import useMultiFetch from "frontend/utils/useMultiFetch";
import usePost from "frontend/utils/usePost";
import { isAuthenticated } from "frontend/utils/authenticateHelper.js";

import { boardSize, rackSize } from "frontend/utils/constants.js";
import { ActionCableConsumer } from "frontend/utils/actionCableProvider";
import AvailableTilesTable from "frontend/components/AvailableTilesTable";
import MoveHistory from "frontend/components/MoveHistory";

const initalBoardValues = Array.from({ length: boardSize }, () =>
  Array.from({ length: boardSize }, () => 0)
);

const initalRackValues = Array.from({ length: rackSize }, () => 0);

const Show = ({
  match: {
    params: { id }
  }
}) => {
  const [boardValues, setBoardValues] = useState(initalBoardValues);
  const [tempBoardValues, setTempBoardValues] = useState(initalBoardValues);
  const [lastMoveInfo, setLastMoveInfo] = useState(null);
  const [gameFlowData, setGameFlowData] = useState({});
  const [playerData, setPlayerData] = useState({});
  const [rackValues, setRackValues] = useState(initalRackValues);
  const [exchanging, setExchanging] = useState(false);
  const [moves, setMoves] = useState([]);
  const is_authenticated = isAuthenticated();

  const { isFetching, hasFetched, fetchError, doFetch } = useMultiFetch(
    [
      `/api/v1/games/${id}`,
      `/api/v1/games/${id}/moves`
    ],
    ({
      json: {
        game: {
          board,
          you,
          them,
          last_move,
          available_tiles,
          your_rack,
          your_turn,
          your_score,
          their_score,
          allow_swap,
          complete,
          your_win
        },
        moves
      }
    }) => {
      setBoardValues(board);
      setRackValues(your_rack);
      setLastMoveInfo(
        last_move &&
          last_move.row_num &&
          last_move.row_num.reduce((map, row, index) => {
            map[row] = map[row]
              ? map[row].concat(last_move.col_num[index])
              : [last_move.col_num[index]];
            return map;
          }, {})
      );
      setTempBoardValues(initalBoardValues);
      setGameFlowData({
        your_turn: your_turn,
        your_score: your_score,
        their_score: their_score,
        allow_swap: allow_swap,
        complete: complete,
        your_win: your_win,
        available_tiles: available_tiles
      });
      setPlayerData({
        you: you,
        them: them
      });
      setMoves(moves);
    }
  );

  const placeTiles = () => {
    var row_num = [];
    var col_num = [];
    var tile_value = [];

    tempBoardValues.forEach((arr, row) => {
      arr.forEach((value, col) => {
        if (value != 0) {
          row_num.push(row);
          col_num.push(col);
          tile_value.push(value);
        }
      });
    });

    return {
      row_num: row_num,
      col_num: col_num,
      tile_value: tile_value
    };
  };

  const { isPosting, hasPosted, postError, doPost } = usePost(
    "/api/v1/moves",
    ({ response, json }) => {
      var status = response.status;
      if (status != 200) {
        alert(`Server responded with ${status}. JSON: ${JSON.stringify(json)}`);
      }
    }
  );

  useEffect(() => {
    if (!is_authenticated) {
      window.location.replace(`/`);
    }
    doFetch();
  }, [is_authenticated]);

  const handleRackSet = (col, value) => {
    var newRack = rackValues.slice();
    newRack[col] = value;
    setRackValues(newRack);
  };

  const handleBoardSet = (row, col, value) => {
    var newBoard = tempBoardValues.map(function(arr) {
      return arr.slice();
    });
    newBoard[row][col] = value;
    setTempBoardValues(newBoard);
  };

  const postTilePlacement = () => {
    doPost({
      move_info: {
        game_id: id,
        move_type: "tile_placement",
        ...placeTiles()
      }
    });
  };

  const postPass = () => {
    doPost({
      move_info: {
        game_id: id,
        move_type: "pass"
      }
    });
  };

  const setExchange = newValue => {
    setExchanging(newValue);
  };

  if (!hasFetched) {
    return (
      <div
        style={{
          backgroundColor: "#D8BFD8",
          width: "100%",
          height: "100%"
        }}
      ></div>
    );
  }

  const renderPlayArea = () => (
    <div className="play-area">
      <div className="play-area-box hidden-on-small-screen">
        <MoveHistory moves={moves} initiator={playerData.you.username}/>
      </div>
      <div className="play-area-box">
        <DndProvider backend={Backend}>
          <Board
            boardValues={boardValues}
            tempBoardValues={tempBoardValues}
            lastMoveInfo={lastMoveInfo}
            handleBoardSet={handleBoardSet}
          />
          <TileRack rackValues={rackValues} handleRackSet={handleRackSet} />
        </DndProvider>
        <button
          className="play-btn"
          onClick={postTilePlacement}
          disabled={!gameFlowData.your_turn}
        >
          PLAY!
        </button>
        <div className="btn-group">
          <button onClick={postPass} disabled={!gameFlowData.your_turn}>
            Pass
          </button>
          <button
            onClick={() => setExchange(true)}
            disabled={!gameFlowData.your_turn || !gameFlowData.allow_swap}
          >
            Exchange tiles
          </button>
        </div>
      </div>
      <div className="play-area-box hidden-on-small-screen">
        <AvailableTilesTable tile_infos={gameFlowData.available_tiles} />
      </div>
    </div>
  );

  const renderGameOver = () => (
    <div>
      <div className="gameover-message">
        <h1>Game Over. {gameFlowData.your_win ? "You Win!" : "They Win!"}</h1>
      </div>
      <DndProvider backend={Backend}>
        <Board boardValues={boardValues} tempBoardValues={initalBoardValues} />
      </DndProvider>
    </div>
  );

  const renderExchange = () => (
    <ExchangeView
      id={id}
      rackValues={rackValues}
      doPost={doPost}
      cancel={() => setExchange(false)}
    />
  );

  const handleReceivedUpdate = response => {
    if (isFetching) {
      return;
    }
    doFetch();
  };

  return (
    <div
      style={{
        backgroundColor: "#D8BFD8",
        padding: "0px 0px 20px 0px",
        overflow: "auto"
      }}
    >
      <ScoreBoard
        yourTurn={gameFlowData.your_turn}
        initiatorUsername={playerData.you.username}
        opponentUsername={playerData.them ? playerData.them.username : null}
        playerScore={gameFlowData.your_score}
        opponentScore={gameFlowData.their_score}
      />
      {gameFlowData.complete
        ? renderGameOver()
        : exchanging
        ? renderExchange()
        : renderPlayArea()}
      <ActionCableConsumer
        channel={{ channel: "GamesChannel" }}
        onReceived={handleReceivedUpdate}
      />
    </div>
  );
};

export default Show;
