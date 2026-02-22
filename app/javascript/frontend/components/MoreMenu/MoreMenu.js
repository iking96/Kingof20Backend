import React, { useState, useEffect, useRef } from "react";
import "./MoreMenu.scss";

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
        <span className="icon">☰</span>
        <span className="label">More</span>
      </button>

      {isOpen && (
        <div className="more-dropdown">
          <button onClick={handleTileDistribution}>
            <span className="icon">📊</span>
            Tile Distribution
          </button>
          <button onClick={handleMoveHistory}>
            <span className="icon">📜</span>
            Move History
          </button>
          <hr className="divider" />
          <button onClick={handleResign} disabled={gameComplete}>
            <span className="icon">🏳️</span>
            Resign
          </button>
        </div>
      )}
    </div>
  );
};

export default React.memo(MoreMenu);
