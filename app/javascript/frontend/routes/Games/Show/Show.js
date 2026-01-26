import React, { useEffect, useState } from "react";
import { DndProvider } from "react-dnd";
import Backend from "react-dnd-html5-backend";

import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import { isAuthenticated } from "frontend/utils/authenticateHelper.js";

import { boardSize, rackSize } from "frontend/utils/constants.js";
import { ActionCableConsumer } from "frontend/utils/actionCableProvider";

import PlayerScoreArea from "frontend/components/PlayerScoreArea";
import MoveHistorySidebar from "frontend/components/MoveHistorySidebar";
import TileDistributionModal from "frontend/components/TileDistributionModal";
import OptionsMenu from "frontend/components/OptionsMenu";
import Board from "frontend/components/Board";
import TileRack from "frontend/components/TileRack";
import ExchangeView from "frontend/components/ExchangeView";

import "../../../../scss/game_container.scss";

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
  const [moves, setMoves] = useState([]);
  const [exchanging, setExchanging] = useState(false);
  const [showTileDistribution, setShowTileDistribution] = useState(false);
  const is_authenticated = isAuthenticated();

  const { isFetching, hasFetched, fetchError, doFetch } = useFetch(
    `/api/v1/games/${id}`,
    ({ response, json }) => {
      var status = response.status;
      if (status != 200) {
        alert(`Server responded with ${status}. JSON: ${JSON.stringify(json)}`);
        window.location.replace(`/`);
      }

      var game = json.game;
      var moves = json.moves;

      var board = game.board;
      var you = game.you;
      var them = game.them;
      var last_move = game.last_move;
      var available_tiles = game.available_tiles;
      var your_rack = game.your_rack;
      var your_turn = game.your_turn;
      var your_score = game.your_score;
      var their_score = game.their_score;
      var allow_swap = game.allow_swap;
      var complete = game.complete;
      var your_win = game.your_win;

      setBoardValues(board);
      setRackValues(your_rack);
      setTempBoardValues(initalBoardValues);
      setGameFlowData({
        id: id,
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
  }, [is_authenticated, id]);

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

  const postExchange = (returned_tiles, callback) => {
    doPost(
      {
        move_info: {
          game_id: id,
          move_type: "swap",
          returned_tiles: returned_tiles
        }
      },
      () => {
        callback();
      }
    );
  };

  const handleReceivedUpdate = response => {
    if (isFetching) {
      return;
    }
    doFetch();
  };

  if (!hasFetched) {
    return (
      <div className="game-container">
        <div className="game-panel">
          <div className="floating-card" style={{ height: "600px" }}></div>
        </div>
      </div>
    );
  }

  return (
    <div className="game-container">
      <div className="game-content-wrapper">
      <div className="game-panel">
        <div className="floating-card">
          <DndProvider backend={Backend}>
            <Board
              boardValues={boardValues}
              tempBoardValues={tempBoardValues}
              lastMoveInfo={lastMoveInfo}
              handleBoardSet={handleBoardSet}
            />

            <div className="controls-row">
              <TileRack rackValues={rackValues} handleRackSet={handleRackSet} />

              <OptionsMenu
                yourTurn={gameFlowData.your_turn}
                allowSwap={gameFlowData.allow_swap}
                gameComplete={gameFlowData.complete}
                onPass={postPass}
                onExchange={() => setExchanging(true)}
                onShowTileDistribution={() => setShowTileDistribution(true)}
              />

              <button
                className="play-btn"
                onClick={postTilePlacement}
                disabled={!gameFlowData.your_turn || gameFlowData.complete}
              >
                PLAY!
              </button>
            </div>
          </DndProvider>

          {gameFlowData.complete && (
            <div className="game-over-message">
              Game Over. {gameFlowData.your_win ? "You Win!" : "They Win!"}
            </div>
          )}
        </div>
      </div>

<div className="game-sidebar">
        <PlayerScoreArea
          yourTurn={gameFlowData.your_turn}
          playerUsername={playerData.you?.username}
          opponentUsername={playerData.them?.username}
          playerScore={gameFlowData.your_score}
          opponentScore={gameFlowData.their_score}
        />
        <MoveHistorySidebar
          moves={moves}
          currentUsername={playerData.you?.username}
        />
      </div>
      </div>

      {exchanging && (
        <div className="exchange-modal-backdrop" onClick={(e) => e.target === e.currentTarget && setExchanging(false)}>
          <div className="exchange-modal">
            <ExchangeView
              rackValues={rackValues}
              postExchange={postExchange}
              cancel={() => setExchanging(false)}
            />
          </div>
        </div>
      )}

      {showTileDistribution && (
        <TileDistributionModal
          availableTiles={gameFlowData.available_tiles}
          onClose={() => setShowTileDistribution(false)}
        />
      )}

      <ActionCableConsumer
        channel={{ channel: "GamesChannel" }}
        onReceived={handleReceivedUpdate}
      />
    </div>
  );
};

export default Show;
