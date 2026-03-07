import React, { useState } from "react";
import Modal from "frontend/components/Modal";
import useField from "frontend/utils/useField";
import "./ResetPasswordModal.scss";

const ResetPasswordModal = ({ resetToken, onClose, onSuccess }) => {
  const [errorMessage, setErrorMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const password = useField("");
  const passwordConfirmation = useField("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMessage("");

    if (password.value !== passwordConfirmation.value) {
      setErrorMessage("Passwords do not match");
      setIsLoading(false);
      return;
    }

    try {
      const response = await fetch("/api/v1/users/password", {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          user: {
            reset_password_token: resetToken,
            password: password.value,
            password_confirmation: passwordConfirmation.value,
          },
        }),
      });

      const json = await response.json();

      if (response.ok) {
        onSuccess();
      } else {
        setErrorMessage(json.errors?.[0] || "Failed to reset password");
      }
    } catch (error) {
      console.error("Password reset error:", error);
      setErrorMessage("Something went wrong. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Modal title="Set New Password" onClose={onClose} maxWidth="360px">
      <div className="reset-password-content">
        <form onSubmit={handleSubmit}>
          <div className="form-field">
            <label htmlFor="password">New Password</label>
            <input
              id="password"
              type="password"
              placeholder="Enter new password"
              value={password.value}
              onChange={password.handleChange}
              required
              autoFocus
              minLength={6}
            />
          </div>
          <div className="form-field">
            <label htmlFor="passwordConfirmation">Confirm Password</label>
            <input
              id="passwordConfirmation"
              type="password"
              placeholder="Confirm new password"
              value={passwordConfirmation.value}
              onChange={passwordConfirmation.handleChange}
              required
              minLength={6}
            />
          </div>
          {errorMessage && <p className="error-message">{errorMessage}</p>}
          <button type="submit" className="submit-btn" disabled={isLoading}>
            {isLoading ? "Resetting..." : "Reset Password"}
          </button>
        </form>
      </div>
    </Modal>
  );
};

export default React.memo(ResetPasswordModal);
