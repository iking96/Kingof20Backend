import React from "react";
import Modal from "frontend/components/Modal";
import "./ConfirmationModal.scss";

const ConfirmationModal = ({
  title,
  message,
  confirmText = "Confirm",
  cancelText = "Cancel",
  onConfirm,
  onCancel,
  variant = "default"
}) => {
  return (
    <Modal title={title} onClose={onCancel} maxWidth="360px">
      <div className="confirmation-modal-content">
        <p className="confirmation-message">{message}</p>
        <div className="confirmation-buttons">
          <button className="cancel-btn" onClick={onCancel}>
            {cancelText}
          </button>
          <button
            className={`confirm-btn ${variant === "danger" ? "danger" : ""}`}
            onClick={onConfirm}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </Modal>
  );
};

export default React.memo(ConfirmationModal);
