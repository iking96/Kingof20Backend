import React from "react";
import { Link } from "react-router-dom";
import "./NavBar.scss";
import logo from "frontend/assets/logo-large.png";

const NavBar = ({ loggedIn, username, onLoginClick, onSignupClick, onLogoutClick, onMenuClick, menuOpen }) => {
  return (
    <nav className="modern-navbar">
      <div className="navbar-content">
        <div className="navbar-left">
          <button
            className={`hamburger-btn ${menuOpen ? 'open' : ''}`}
            onClick={onMenuClick}
            aria-label="Toggle menu"
          >
            <span></span>
            <span></span>
            <span></span>
          </button>
          <Link to="/" className="logo-link">
            <img src={logo} alt="King of 20" className="logo-image" />
          </Link>
        </div>

        <div className="navbar-center">
          <Link to="/games/how-to-play" className="nav-link">
            How to Play
          </Link>
        </div>

        <div className="navbar-right">
          {loggedIn ? (
            <div className="user-info">
              <Link to={`/users/${username}`} className="user-profile">
                <div className="user-avatar">
                  {username ? username.charAt(0).toUpperCase() : "U"}
                </div>
                <span className="username">{username || "User"}</span>
              </Link>
              <button className="btn-logout" onClick={onLogoutClick}>
                Logout
              </button>
            </div>
          ) : (
            <div className="auth-buttons">
              <button className="btn-login" onClick={onLoginClick}>
                Login
              </button>
              <button className="btn-signup" onClick={onSignupClick}>
                Sign Up
              </button>
            </div>
          )}
        </div>
      </div>
    </nav>
  );
};

export default NavBar;
