import React from "react";
import { humanizedDate } from "frontend/utils/date_util";

const ScrollView = props => {
  return <div className="scroller">{props.children}</div>;
};

const MoveHistoryScroll = ({ moves, you, onIndexClick }) => {
  return (
    <div>
      <div style={{width: '300px', margin: 'auto'}}>
        View move by selecting one from list below!
      </div>
      <ScrollView>
        <div className="move-message-list">
          {moves
            .slice(0)
            .reverse()
            .map((move, index) => (
              <div
                className={
                  "move-message-row" +
                  `${move.username == you ? " you-message" : " them-message"}`
                }
                key={index}
                onClick={() => onIndexClick(index)}
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
    </div>
  );
};

export default MoveHistoryScroll;
