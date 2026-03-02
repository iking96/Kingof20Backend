import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Cookies from "js-cookie";
import { getAccessToken } from "frontend/utils/authenticateHelper.js";
import usePatch from "frontend/utils/usePatch";
import "./UserProfile.scss";

const UserProfile = () => {
  const { username: usernameParam } = useParams();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isOwnProfile, setIsOwnProfile] = useState(false);
  const [editingEmail, setEditingEmail] = useState(false);
  const [emailInput, setEmailInput] = useState("");
  const [saveMessage, setSaveMessage] = useState(null);

  const { isPatching, doPatch } = usePatch("/api/v1/users/me");

  const currentUsername = Cookies.get("username");

  const handleSaveEmail = () => {
    setSaveMessage(null);
    doPatch({ user: { email: emailInput } }, ({ response, json }) => {
      if (response.ok) {
        setUser({ ...user, email: json.user.email });
        setEditingEmail(false);
        setSaveMessage({ type: "success", text: "Email updated successfully" });
      } else {
        setSaveMessage({ type: "error", text: json.errors?.[0] || "Failed to update email" });
      }
    });
  };

  const handleCancelEdit = () => {
    setEditingEmail(false);
    setEmailInput(user?.email || "");
    setSaveMessage(null);
  };

  useEffect(() => {
    const fetchUser = async () => {
      const isOwn = currentUsername && currentUsername === usernameParam;
      setIsOwnProfile(isOwn);

      try {
        const url = isOwn ? "/api/v1/users/me" : `/api/v1/users/${encodeURIComponent(usernameParam)}`;
        const opts = isOwn
          ? {
              headers: {
                AUTHORIZATION: `Bearer ${getAccessToken()}`,
                Accept: "application/json"
              }
            }
          : {};

        const response = await fetch(url, opts);
        const data = await response.json();

        if (response.ok) {
          setUser(data.user);
          setEmailInput(data.user.email || "");
        } else {
          setError(data.error || "User not found");
        }
      } catch (err) {
        setError("Failed to load user profile");
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [usernameParam, currentUsername]);

  if (loading) {
    return (
      <div className="user-profile-page">
        <div className="user-profile-content">
          <div className="loading">Loading...</div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="user-profile-page">
        <div className="user-profile-content">
          <div className="error-state">{error}</div>
        </div>
      </div>
    );
  }

  const { username, created_at, stats } = user;
  const joinDate = new Date(created_at).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric"
  });

  return (
    <div className="user-profile-page">
      <div className="user-profile-content">
        <div className="profile-header">
          <div className="avatar-large">
            {username.charAt(0).toUpperCase()}
          </div>
          <div className="profile-info">
            <h1 className="profile-username">{username}</h1>
            <p className="join-date">Joined {joinDate}</p>
          </div>
        </div>

        <div className="stats-grid">
          <div className="stat-card">
            <div className="stat-value">{stats.games_played}</div>
            <div className="stat-label">Games Played</div>
          </div>

          <div className="stat-card">
            <div className="stat-value">{stats.average_score}</div>
            <div className="stat-label">Avg Game Score</div>
          </div>
        </div>

        <div className="win-rate-section">
          <div className="win-rate-header">
            <span className="win-rate-label">Win Rate</span>
            <span className="win-rate-value">{stats.win_rate}%</span>
          </div>
          <div className="win-rate-bar">
            <div
              className="win-rate-fill"
              style={{ width: `${stats.win_rate}%` }}
            />
          </div>
          <div className="win-loss-counts">
            <span className="wins-count">{stats.wins}W</span>
            <span className="losses-count">{stats.losses}L</span>
          </div>
        </div>

        {isOwnProfile && (
          <div className="email-section">
            <div className="section-title">Email</div>
            {saveMessage && (
              <div className={`save-message ${saveMessage.type}`}>
                {saveMessage.text}
              </div>
            )}
            {editingEmail ? (
              <div className="email-edit-form">
                <input
                  type="email"
                  value={emailInput}
                  onChange={(e) => setEmailInput(e.target.value)}
                  placeholder="Enter your email"
                  className="email-input"
                />
                <div className="email-buttons">
                  <button
                    className="cancel-btn"
                    onClick={handleCancelEdit}
                    disabled={isPatching}
                  >
                    Cancel
                  </button>
                  <button
                    className="save-btn"
                    onClick={handleSaveEmail}
                    disabled={isPatching}
                  >
                    {isPatching ? "Saving..." : "Save"}
                  </button>
                </div>
              </div>
            ) : (
              <div className="email-display">
                <span className="email-value">
                  {user.email || "No email set"}
                </span>
                <button
                  className="edit-btn"
                  onClick={() => setEditingEmail(true)}
                >
                  {user.email ? "Change" : "Add"}
                </button>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default UserProfile;
