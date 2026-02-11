import React, { useState } from "react";
import Cookies from "js-cookie";
import Modal from "frontend/components/Modal";
import useField from "frontend/utils/useField";
import { CLIENT_ID } from "frontend/utils/constants.js";
import "./SignupModal.scss";

const SignupModal = ({ onClose, onLogin, onSwitchToLogin }) => {
  const [errorMessage, setErrorMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const username = useField("");
  const password = useField("");
  const email = useField("");

  const loginAfterSignup = async (usernameValue, passwordValue) => {
    try {
      const response = await fetch("/oauth/token", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: new URLSearchParams({
          grant_type: "password",
          username: usernameValue,
          password: passwordValue,
          client_id: CLIENT_ID
        })
      });

      const json = await response.json();

      if (response.status === 200) {
        Cookies.set("access_token", json.access_token);
        Cookies.set("username", usernameValue);
        onLogin();
        onClose();
      } else {
        // Account created but login failed - switch to login modal
        onSwitchToLogin();
      }
    } catch (error) {
      console.error("Auto-login error:", error);
      onSwitchToLogin();
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMessage("");

    try {
      const response = await fetch(
        `/api/v1/users?user[username]=${username.value}&user[password]=${password.value}&user[email]=${email.value}`,
        { method: "POST" }
      );

      const json = await response.json();

      if (response.status === 200) {
        // Auto-login after successful signup
        await loginAfterSignup(username.value, password.value);
      } else {
        // Format error message from API response
        if (json.errors) {
          const errorMessages = Object.entries(json.errors)
            .map(([field, msgs]) => `${field} ${msgs.join(", ")}`)
            .join(". ");
          setErrorMessage(errorMessages);
        } else {
          setErrorMessage("Failed to create account. Please try again.");
        }
      }
    } catch (error) {
      console.error("Signup error:", error);
      setErrorMessage("Something went wrong. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Modal title="Sign Up" onClose={onClose} maxWidth="360px">
      <div className="signup-modal-content">
        <form onSubmit={handleSubmit}>
          <div className="form-field">
            <label htmlFor="signup-username">Username</label>
            <input
              id="signup-username"
              type="text"
              placeholder="Choose a username"
              value={username.value}
              onChange={username.handleChange}
              required
              autoFocus
            />
          </div>
          <div className="form-field">
            <label htmlFor="signup-password">Password</label>
            <input
              id="signup-password"
              type="password"
              placeholder="Choose a password"
              value={password.value}
              onChange={password.handleChange}
              required
            />
          </div>
          <div className="form-field">
            <label htmlFor="signup-email">Email (optional)</label>
            <input
              id="signup-email"
              type="email"
              placeholder="Enter your email"
              value={email.value}
              onChange={email.handleChange}
            />
          </div>
          {errorMessage && (
            <p className="error-message">{errorMessage}</p>
          )}
          <button type="submit" className="submit-btn" disabled={isLoading}>
            {isLoading ? "Creating account..." : "Create Account"}
          </button>
        </form>
        <div className="login-prompt">
          Already have an account?{" "}
          <button type="button" className="link-btn" onClick={onSwitchToLogin}>
            Log in here
          </button>
        </div>
      </div>
    </Modal>
  );
};

export default React.memo(SignupModal);
