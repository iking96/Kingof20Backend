import React from "react";
import Modal from "frontend/components/Modal";
import AvailableTilesTable from "frontend/components/AvailableTilesTable";
import "./TileDistributionModal.scss";

const TileDistributionModal = ({ availableTiles, onClose }) => {
  return (
    <Modal title="Tile Distribution" onClose={onClose}>
      <AvailableTilesTable tile_infos={availableTiles} />
    </Modal>
  );
};

export default React.memo(TileDistributionModal);
