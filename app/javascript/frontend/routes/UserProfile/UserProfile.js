import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import "./UserProfile.scss";

const UserProfile = () => {
  const { username: usernameParam } = useParams();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const response = await fetch(`/api/v1/users/${encodeURIComponent(usernameParam)}`);
        const data = await response.json();

        if (response.ok) {
          setUser(data.user);
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
  }, [usernameParam]);

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
            <p className="join-date">Member since {joinDate}</p>
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
      </div>
    </div>
  );
};

export default UserProfile;
