import React, { useEffect, useState } from "react";
import { useHistory } from "react-router-dom";
import { DndProvider } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";
import { TouchBackend } from "react-dnd-touch-backend";

const isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
const Backend = isTouchDevice ? TouchBackend : HTML5Backend;

import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import { isAuthenticated, getAccessToken } from "frontend/utils/authenticateHelper.js";

import { boardSize, rackSize } from "frontend/utils/constants.js";
import { ActionCableConsumer } from "frontend/utils/actionCableProvider";

import PlayerScoreArea from "frontend/components/PlayerScoreArea";
import MoveHistorySidebar from "frontend/components/MoveHistorySidebar";
import TileDistributionModal from "frontend/components/TileDistributionModal";
import Modal from "frontend/components/Modal";
import ConfirmationModal from "frontend/components/ConfirmationModal";
import ErrorModal from "frontend/components/ErrorModal";
import OptionsMenu from "frontend/components/OptionsMenu";
import Board from "frontend/components/Board";
import TileRack from "frontend/components/TileRack";
import ExchangeView from "frontend/components/ExchangeView";
import GameInfoBar from "frontend/components/GameInfoBar";

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
  const history = useHistory();
  const [boardValues, setBoardValues] = useState(initalBoardValues);
  const [tempBoardValues, setTempBoardValues] = useState(initalBoardValues);
  const [lastMoveInfo, setLastMoveInfo] = useState(null);
  const [gameFlowData, setGameFlowData] = useState({});
  const [playerData, setPlayerData] = useState({});
  const [rackValues, setRackValues] = useState(initalRackValues);
  const [moves, setMoves] = useState([]);
  const [exchanging, setExchanging] = useState(false);
  const [showTileDistribution, setShowTileDistribution] = useState(false);
  const [showPassConfirm, setShowPassConfirm] = useState(false);
  const [showResignConfirm, setShowResignConfirm] = useState(false);
  const [errorMessage, setErrorMessage] = useState(null);
  const is_authenticated = isAuthenticated();

  const triggerAiMove = () => {
    fetch("/api/v1/moves/ai_move", {
      headers: {
        AUTHORIZATION: `Bearer ${getAccessToken()}`,
        "Content-Type": "application/json",
        Accept: "application/json"
      },
      credentials: "same-origin",
      method: "POST",
      body: JSON.stringify({ game_id: id })
    });
  };

  const { isFetching, hasFetched, fetchError, doFetch } = useFetch(
    `/api/v1/games/${id}`,
    ({ response, json }) => {
      var status = response.status;
      if (status != 200) {
        setErrorMessage("Unable to load game. Redirecting...");
        setTimeout(() => window.location.replace(`/`), 2000);
        return;
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
      var stage = game.stage;

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
        available_tiles: available_tiles,
        vs_computer: game.vs_computer,
        stage: stage
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
      if (status === 422) {
        // Unprocessable entity - show the validation message
        setErrorMessage(json?.message || "Invalid move. Please try again.");
      } else if (status != 200) {
        // Other errors - generic message
        setErrorMessage("Something went wrong. Please try again.");
      } else if (gameFlowData.vs_computer) {
        setTimeout(triggerAiMove, 100);
      }
    }
  );

  useEffect(() => {
    if (!is_authenticated) {
      history.replace('/games/how-to-play');
      return;
    }
    doFetch();
  }, [is_authenticated, id, history]);

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

  const recallTiles = () => {
    const tilesToRecall = [];
    const newTempBoard = tempBoardValues.map(arr => arr.slice());

    // Collect tiles from temp board and clear them
    newTempBoard.forEach((row, rowIdx) => {
      row.forEach((value, colIdx) => {
        if (value !== 0) {
          tilesToRecall.push(value);
          newTempBoard[rowIdx][colIdx] = 0;
        }
      });
    });

    // Return tiles to empty rack slots
    const newRack = rackValues.slice();
    for (let i = 0; i < newRack.length && tilesToRecall.length > 0; i++) {
      if (newRack[i] === 0) {
        newRack[i] = tilesToRecall.shift();
      }
    }

    setTempBoardValues(newTempBoard);
    setRackValues(newRack);
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
    setShowPassConfirm(false);
    doPost({
      move_info: {
        game_id: id,
        move_type: "pass"
      }
    });
  };

  const postResign = () => {
    setShowResignConfirm(false);
    fetch(`/api/v1/games/${id}`, {
      headers: {
        AUTHORIZATION: `Bearer ${getAccessToken()}`,
        "Content-Type": "application/json",
        Accept: "application/json"
      },
      credentials: "same-origin",
      method: "PATCH",
      body: JSON.stringify({ forfit: true })
    }).then(() => {
      doFetch();
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
                  onPass={() => setShowPassConfirm(true)}
                  onExchange={() => {
                    recallTiles();
                    setExchanging(true);
                  }}
                  onResign={() => setShowResignConfirm(true)}
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

          </div>
        </div>
        <div className="game-sidebar">
          <GameInfoBar
            tilesRemaining={gameFlowData.available_tiles?.length || 0}
            stage={gameFlowData.stage}
            complete={gameFlowData.complete}
            yourWin={gameFlowData.your_win}
          />
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
        <Modal title="Exchange Tiles" onClose={() => setExchanging(false)} maxWidth="500px">
          <ExchangeView
            rackValues={rackValues}
            postExchange={postExchange}
            cancel={() => setExchanging(false)}
          />
        </Modal>
      )}

      {showTileDistribution && (
        <TileDistributionModal
          availableTiles={gameFlowData.available_tiles}
          onClose={() => setShowTileDistribution(false)}
        />
      )}

      {showPassConfirm && (
        <ConfirmationModal
          title="Pass Turn"
          message="Are you sure you want to pass your turn?"
          confirmText="Pass"
          cancelText="Cancel"
          onConfirm={postPass}
          onCancel={() => setShowPassConfirm(false)}
        />
      )}

      {showResignConfirm && (
        <ConfirmationModal
          title="Resign"
          message="Are you sure you want to resign? This will end the game and count as a loss."
          confirmText="Resign"
          cancelText="Cancel"
          onConfirm={postResign}
          onCancel={() => setShowResignConfirm(false)}
          variant="danger"
        />
      )}

      {errorMessage && (
        <ErrorModal
          title="Invalid Move"
          message={errorMessage}
          onClose={() => setErrorMessage(null)}
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
