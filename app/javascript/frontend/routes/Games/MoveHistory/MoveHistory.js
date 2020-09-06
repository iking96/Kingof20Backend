import React, { useEffect, useState } from "react";
import { DndProvider } from "react-dnd";
import Backend from "react-dnd-html5-backend";

import useMultiFetch from "frontend/utils/useMultiFetch";
import { isAuthenticated } from "frontend/utils/authenticateHelper.js";
import { boardSize, rackSize } from "frontend/utils/constants.js";

import ScoreBoard from "frontend/components/ScoreBoard";
import Board from "frontend/components/Board";
import AvailableTilesTable from "frontend/components/AvailableTilesTable";
import MoveHistoryScroll from "frontend/components/MoveHistoryScroll";
const is_authenticated = isAuthenticated();

import { Link } from "react-router-dom";

const initalBoardValues = Array.from({ length: boardSize }, () =>
  Array.from({ length: boardSize }, () => 0)
);

const MoveHistory = ({
  match: {
    params: { id }
  }
}) => {
  const [boardValues, setBoardValues] = useState(initalBoardValues);
  const [gameFlowData, setGameFlowData] = useState({});
  const [playerData, setPlayerData] = useState({});
  const [moves, setMoves] = useState([]);
  const [selectedMove, setSelectedMove] = useState(0);

  const { isFetching, hasFetched, fetchError, doFetch } = useMultiFetch(
    [`/api/v1/games/${id}`, `/api/v1/games/${id}/moves`],
    ({ responses, json }) => {
      var error_status_index = responses.findIndex(
        response => response.status != 200
      );
      if (error_status_index != -1) {
        alert(
          `Server responded with ${
            responses[error_status_index].status
          }. JSON: ${JSON.stringify(json)}`
        );
        window.location.replace(`/`);
      }

      var game = json.game;
      var moves = json.moves;

      var board = game.board;
      var you = game.you;
      var them = game.them;
      var your_turn = game.your_turn;
      var your_score = game.your_score;
      var their_score = game.their_score;

      setBoardValues(board);
      setGameFlowData({
        your_turn: your_turn,
        your_score: your_score,
        their_score: their_score
      });
      setPlayerData({
        you: you,
        them: them
      });
      setMoves(moves);
    }
  );

  useEffect(() => {
    if (!is_authenticated) {
      window.location.replace(`/`);
    }
    doFetch();
  }, [is_authenticated]);

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

  const calculateBoardValues = () => {
    var moves_to_undo = moves.slice(0).reverse().slice(0, selectedMove);
    var calculatedBoard = boardValues.map(function(arr) {
      return arr.slice();
    });

    moves_to_undo.forEach((move) => {
      if (move.move_type != 'tile_placement') {
        return;
      }

      move.row_num.forEach((row, index) => {
        var row = move.row_num[index];
        var col = move.col_num[index];
        calculatedBoard[row][col] = 0;
      });
    });

    return calculatedBoard;
  };

  const calculateLastMoveInfo = () => {
    var selected_move = moves[moves.length - 1 - selectedMove];
    return selected_move &&
      selected_move.row_num &&
      selected_move.row_num.reduce((map, row, index) => {
        map[row] = map[row]
          ? map[row].concat(selected_move.col_num[index])
          : [selected_move.col_num[index]];
        return map;
      }, {})
  };

  return (
    <div
      style={{
        backgroundColor: "#D8BFD8",
        height: "auto",
        minHeight: "100%",
        paddingBottom: "10px"
      }}
    >
      <ScoreBoard
        yourTurn={gameFlowData.your_turn}
        initiatorUsername={playerData.you.username}
        opponentUsername={playerData.them ? playerData.them.username : null}
        playerScore={gameFlowData.your_score}
        opponentScore={gameFlowData.their_score}
      />
      <Link to={`/games/${id}`}>
        <button>Back</button>
      </Link>
      <DndProvider backend={Backend}>
        <Board
          boardValues={calculateBoardValues()}
          tempBoardValues={initalBoardValues}
          lastMoveInfo={calculateLastMoveInfo()}
          handleBoardSet={() => {}}
        />
      </DndProvider>
      <MoveHistoryScroll
        moves={moves}
        you={playerData.you.username}
        onIndexClick={(index) => setSelectedMove(index)}
      />
    </div>
  );
};

export default MoveHistory;
