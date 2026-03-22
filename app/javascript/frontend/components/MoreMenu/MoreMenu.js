import React, { useState, useEffect, useRef } from "react";
import "./MoreMenu.scss";
import moreIcon from "frontend/assets/icons/icon-more.png";
import tileDistIcon from "frontend/assets/icons/icon-tile-distribution.png";
import moveHistoryIcon from "frontend/assets/icons/icon-move-history.png";
import resignIcon from "frontend/assets/icons/icon-resign.png";

const MoreMenu = ({
  gameComplete,
  onResign,
  onShowTileDistribution,
  onShowMoveHistory,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleTileDistribution = () => {
    onShowTileDistribution();
    setIsOpen(false);
  };

  const handleMoveHistory = () => {
    onShowMoveHistory();
    setIsOpen(false);
  };

  const handleResign = () => {
    onResign();
    setIsOpen(false);
  };

  return (
    <div className="more-menu" ref={menuRef}>
      <button
        className="more-trigger"
        onClick={() => setIsOpen(!isOpen)}
        aria-expanded={isOpen}
        aria-haspopup="true"
      >
        <img src={moreIcon} className="icon" alt="" aria-hidden="true" />
        <span className="label">More</span>
      </button>

      {isOpen && (
        <div className="more-dropdown">
          <button onClick={handleTileDistribution}>
            <img src={tileDistIcon} className="icon" alt="" aria-hidden="true" />
            Tile Distribution
          </button>
          <button onClick={handleMoveHistory}>
            <img src={moveHistoryIcon} className="icon" alt="" aria-hidden="true" />
            Move History
          </button>
          <button onClick={handleResign} disabled={gameComplete}>
            <img src={resignIcon} className="icon" alt="" aria-hidden="true" />
            Resign
          </button>
        </div>
      )}
    </div>
  );
};

export default React.memo(MoreMenu);
