import React from "react";
import { Link } from "react-router-dom";
import "./NavBar.scss";
import logo from "frontend/assets/logo-large.png";

const NavBar = ({ loggedIn, username }) => {
  return (
    <nav className="modern-navbar">
      <div className="navbar-content">
        <div className="navbar-left">
          <Link to="/" className="logo-link">
            <img src={logo} alt="King of 20" className="logo-image" />
          </Link>
        </div>

        <div className="navbar-center">
          {loggedIn && (
            <div className="nav-links">
              <Link to="/games" className="nav-link">
                Games
              </Link>
            </div>
          )}
        </div>

        <div className="navbar-right">
          {loggedIn ? (
            <div className="user-info">
              <div className="user-profile">
                <div className="user-avatar">
                  {username ? username.charAt(0).toUpperCase() : "U"}
                </div>
                <span className="username">{username || "User"}</span>
              </div>
              <Link to="/login" className="btn-logout">
                Logout
              </Link>
            </div>
          ) : (
            <div className="auth-buttons">
              <Link to="/login" className="btn-login">
                Login
              </Link>
              <Link to="/signup" className="btn-signup">
                Sign Up
              </Link>
            </div>
          )}
        </div>
      </div>
    </nav>
  );
};

export default NavBar;
