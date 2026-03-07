import React, { useState } from "react";
import Modal from "frontend/components/Modal";
import useField from "frontend/utils/useField";
import "./ForgotPasswordModal.scss";

const ForgotPasswordModal = ({ onClose, onBackToLogin }) => {
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const email = useField("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMessage("");
    setSuccessMessage("");

    try {
      const response = await fetch("/api/v1/users/password", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          user: { email: email.value },
        }),
      });

      const json = await response.json();

      if (response.ok) {
        setSuccessMessage(json.message || "Check your email for reset instructions");
      } else {
        setErrorMessage(json.errors?.[0] || "Failed to send reset email");
      }
    } catch (error) {
      console.error("Password reset error:", error);
      setErrorMessage("Something went wrong. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Modal title="Reset Password" onClose={onClose} maxWidth="360px">
      <div className="forgot-password-content">
        {successMessage ? (
          <div className="success-state">
            <p className="success-message">{successMessage}</p>
            <button type="button" className="back-btn" onClick={onBackToLogin}>
              Back to Login
            </button>
          </div>
        ) : (
          <>
            <p className="instructions">
              Enter your email address and we'll send you instructions to reset
              your password.
            </p>
            <form onSubmit={handleSubmit}>
              <div className="form-field">
                <label htmlFor="email">Email</label>
                <input
                  id="email"
                  type="email"
                  placeholder="Enter your email"
                  value={email.value}
                  onChange={email.handleChange}
                  required
                  autoFocus
                />
              </div>
              {errorMessage && (
                <p className="error-message">{errorMessage}</p>
              )}
              <button type="submit" className="submit-btn" disabled={isLoading}>
                {isLoading ? "Sending..." : "Send Reset Email"}
              </button>
            </form>
            <div className="back-prompt">
              <button type="button" className="link-btn" onClick={onBackToLogin}>
                Back to Login
              </button>
            </div>
          </>
        )}
      </div>
    </Modal>
  );
};

export default React.memo(ForgotPasswordModal);
