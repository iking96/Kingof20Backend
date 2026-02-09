import React from "react";
import Modal from "frontend/components/Modal";
import "./ErrorModal.scss";

const ErrorModal = ({
  title = "Error",
  message,
  onClose
}) => {
  return (
    <Modal title={title} onClose={onClose} maxWidth="360px">
      <div className="error-modal-content">
        <p className="error-message">{message}</p>
      </div>
    </Modal>
  );
};

export default React.memo(ErrorModal);
