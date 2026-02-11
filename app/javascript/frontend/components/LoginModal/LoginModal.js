import React, { useState } from "react";
import Cookies from "js-cookie";
import Modal from "frontend/components/Modal";
import useField from "frontend/utils/useField";
import { CLIENT_ID } from "frontend/utils/constants.js";
import "./LoginModal.scss";

const LoginModal = ({ onClose, onLogin, onSwitchToSignup }) => {
  const [errorMessage, setErrorMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const username = useField("");
  const password = useField("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMessage("");

    try {
      const response = await fetch("/oauth/token", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: new URLSearchParams({
          grant_type: "password",
          username: username.value,
          password: password.value,
          client_id: CLIENT_ID
        })
      });

      const json = await response.json();

      if (response.status === 200) {
        Cookies.set("access_token", json.access_token);
        Cookies.set("username", username.value);
        onLogin();
        onClose();
      } else {
        setErrorMessage(json.message || "Invalid username or password");
      }
    } catch (error) {
      console.error("Login error:", error);
      setErrorMessage("Something went wrong. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Modal title="Log In" onClose={onClose} maxWidth="360px">
      <div className="login-modal-content">
        <form onSubmit={handleSubmit}>
          <div className="form-field">
            <label htmlFor="username">Username</label>
            <input
              id="username"
              type="text"
              placeholder="Enter your username"
              value={username.value}
              onChange={username.handleChange}
              required
              autoFocus
            />
          </div>
          <div className="form-field">
            <label htmlFor="password">Password</label>
            <input
              id="password"
              type="password"
              placeholder="Enter your password"
              value={password.value}
              onChange={password.handleChange}
              required
            />
          </div>
          {errorMessage && (
            <p className="error-message">{errorMessage}</p>
          )}
          <button type="submit" className="submit-btn" disabled={isLoading}>
            {isLoading ? "Logging in..." : "Log In"}
          </button>
        </form>
        <div className="signup-prompt">
          No account?{" "}
          <button type="button" className="link-btn" onClick={onSwitchToSignup}>
            Sign up here
          </button>
        </div>
      </div>
    </Modal>
  );
};

export default React.memo(LoginModal);
