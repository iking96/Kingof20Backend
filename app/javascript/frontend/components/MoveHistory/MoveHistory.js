import React from "react";
import { humanizedDate } from "frontend/utils/date_util";

const ScrollView = props => {
  return <div className="scroller">{props.children}</div>;
};

const MoveHistory = ({ moves, initiator }) => {
  return (
    <ScrollView>
      <div className="move-message-list">
        {moves.map((move, index) => (
          <div
            className={
              "move-message-row" +
              `${move.username == initiator ? " you-message" : " them-message"}`
            }
            key={index}
          >
            <div className="message-text">
              {move.username} for {move.result}
            </div>
            <div className="message-time">
              {humanizedDate(new Date(move.created_at))}
            </div>
          </div>
        ))}
      </div>
    </ScrollView>
  );
};

export default MoveHistory;
