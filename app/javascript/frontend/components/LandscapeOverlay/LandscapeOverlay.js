import React from "react";
import "./LandscapeOverlay.scss";

const LandscapeOverlay = () => {
  return (
    <div className="landscape-overlay">
      <div className="landscape-overlay-content">
        <span className="rotate-icon">📱</span>
        <h2>Please Rotate Your Device</h2>
        <p>This game is best played in portrait mode</p>
      </div>
    </div>
  );
};

export default LandscapeOverlay;
