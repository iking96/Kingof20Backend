import React from "react";
import { humanizedDate } from "frontend/utils/date_util";
import "./MoveHistorySidebar.scss";

const MoveHistorySidebar = ({ moves, currentUsername }) => {
  if (!moves || moves.length === 0) {
    return (
      <div className="move-history-sidebar">
        <div className="sidebar-header">
          <h3>Move History</h3>
        </div>
        <div className="sidebar-content">
          <div className="empty-state">No moves yet. Make the first move!</div>
        </div>
      </div>
    );
  }

  return (
    <div className="move-history-sidebar">
      <div className="sidebar-header">
        <h3>Move History</h3>
        <span className="move-count">{moves.length} moves</span>
      </div>
      <div className="sidebar-content">
        <div className="moves-list">
          {moves
            .slice(0)
            .reverse()
            .map((move, index) => (
              <div
                className={`move-item ${
                  move.username === currentUsername ? "your-move" : "their-move"
                }`}
                key={index}
              >
                <div className="move-info">
                  <span className="move-player">{move.username}</span>
                  <span className="move-result">{move.result}</span>
                </div>
                <div className="move-time">
                  {humanizedDate(new Date(move.created_at))}
                </div>
              </div>
            ))}
        </div>
      </div>
    </div>
  );
};

export default React.memo(MoveHistorySidebar);
