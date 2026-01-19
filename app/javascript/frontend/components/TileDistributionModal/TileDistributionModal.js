import React from "react";
import AvailableTilesTable from "frontend/components/AvailableTilesTable";
import "./TileDistributionModal.scss";

const TileDistributionModal = ({ availableTiles, onClose }) => {
  const handleBackdropClick = (e) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div className="tile-distribution-modal-backdrop" onClick={handleBackdropClick}>
      <div className="tile-distribution-modal">
        <div className="modal-header">
          <h3>Tile Distribution</h3>
          <button className="close-btn" onClick={onClose}>
            &times;
          </button>
        </div>
        <div className="modal-content">
          <AvailableTilesTable tile_infos={availableTiles} />
        </div>
      </div>
    </div>
  );
};

export default React.memo(TileDistributionModal);
