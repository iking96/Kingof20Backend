import React, { useState, useEffect, useRef } from "react";
import "./OptionsMenu.scss";

const OptionsMenu = ({
  yourTurn,
  allowSwap,
  gameComplete,
  onPass,
  onExchange,
  onResign,
  onShowTileDistribution,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef(null);

  const isDisabled = !yourTurn || gameComplete;

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handlePass = () => {
    onPass();
    setIsOpen(false);
  };

  const handleExchange = () => {
    onExchange();
    setIsOpen(false);
  };

  const handleTileDistribution = () => {
    onShowTileDistribution();
    setIsOpen(false);
  };

  const handleResign = () => {
    onResign();
    setIsOpen(false);
  };

  return (
    <div className="options-menu" ref={menuRef}>
      <button
        className="options-trigger"
        onClick={() => setIsOpen(!isOpen)}
        aria-expanded={isOpen}
        aria-haspopup="true"
        title="Game Options"
      >
        ☰
      </button>

      {isOpen && (
        <div className="options-dropdown">
          <button onClick={handlePass} disabled={isDisabled}>
            <span className="icon">⏭</span>
            Pass Turn
          </button>
          <button
            onClick={handleExchange}
            disabled={isDisabled || !allowSwap}
          >
            <span className="icon">🔄</span>
            Exchange Tiles
          </button>
          <hr className="divider" />
          <button onClick={handleTileDistribution}>
            <span className="icon">📊</span>
            Tile Distribution
          </button>
          <button onClick={handleResign} disabled={gameComplete}>
            <span className="icon">🏳️</span>
            Resign
          </button>
        </div>
      )}
    </div>
  );
};

export default React.memo(OptionsMenu);
