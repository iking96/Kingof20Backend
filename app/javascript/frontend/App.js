import React from "react";
import "./App.css";

import { BrowserRouter, Switch, Route, Redirect } from "react-router-dom";
//Reference: https://github.com/cpunion/react-actioncable-provider/blob/master/lib/index.js
import { ActionCableProvider } from "frontend/utils/actionCableProvider";

import { GamesLayout, GamesRoutes } from "frontend/routes/Games";
import UserProfile from "frontend/routes/UserProfile";
import NavBar from "frontend/components/NavBar";
import LoginModal from "frontend/components/LoginModal";
import SignupModal from "frontend/components/SignupModal";
import ConfirmationModal from "frontend/components/ConfirmationModal";
import ForgotPasswordModal from "frontend/components/ForgotPasswordModal";
import ResetPasswordModal from "frontend/components/ResetPasswordModal";
import { isAuthenticated, getAccessToken } from "frontend/utils/authenticateHelper.js";
import { config } from "frontend/utils/constants.js";
import Cookies from "js-cookie";

class App extends React.Component {
  constructor(props) {
    super(props);
    // Check for password reset token in URL
    const urlParams = new URLSearchParams(window.location.search);
    const resetToken = urlParams.get('reset_password_token');

    this.state = {
      loggedIn: isAuthenticated(),
      showLoginModal: false,
      showSignupModal: false,
      showLogoutModal: false,
      showForgotPasswordModal: false,
      showResetPasswordModal: !!resetToken,
      resetPasswordToken: resetToken,
      sidebarOpen: false,
      cableUrl: `${config.url.API_WS_ROOT}?access_token=${getAccessToken()}`
    };
    this.setLogin = this.setLogin.bind(this);
    this.handleLogout = this.handleLogout.bind(this);
    this.openLoginModal = this.openLoginModal.bind(this);
    this.openSignupModal = this.openSignupModal.bind(this);
    this.openLogoutModal = this.openLogoutModal.bind(this);
    this.openForgotPasswordModal = this.openForgotPasswordModal.bind(this);
    this.closeModals = this.closeModals.bind(this);
    this.switchToSignup = this.switchToSignup.bind(this);
    this.switchToLogin = this.switchToLogin.bind(this);
    this.handlePasswordResetSuccess = this.handlePasswordResetSuccess.bind(this);
    this.toggleSidebar = this.toggleSidebar.bind(this);
    this.closeSidebar = this.closeSidebar.bind(this);
  }

  setLogin(loginState) {
    // Update cable URL on login to use new access token
    this.setState({
      loggedIn: loginState,
      cableUrl: `${config.url.API_WS_ROOT}?access_token=${getAccessToken()}`
    });
  }

  handleLogout() {
    Cookies.remove("access_token");
    Cookies.remove("username");
    // Clear cable URL on logout to disconnect
    this.setState({
      loggedIn: false,
      showLogoutModal: false,
      cableUrl: null
    });
  }

  openLogoutModal() {
    this.setState({ showLogoutModal: true });
  }

  openLoginModal() {
    this.setState({ showLoginModal: true, showSignupModal: false });
  }

  openSignupModal() {
    this.setState({ showSignupModal: true, showLoginModal: false });
  }

  openForgotPasswordModal() {
    this.setState({ showForgotPasswordModal: true, showLoginModal: false });
  }

  closeModals() {
    this.setState({
      showLoginModal: false,
      showSignupModal: false,
      showLogoutModal: false,
      showForgotPasswordModal: false,
      showResetPasswordModal: false,
      resetPasswordToken: null
    });
    // Clean up URL if there was a reset token
    if (window.location.search.includes('reset_password_token')) {
      window.history.replaceState({}, '', window.location.pathname);
    }
  }

  handlePasswordResetSuccess() {
    this.closeModals();
    this.openLoginModal();
  }

  switchToSignup() {
    this.setState({ showLoginModal: false, showSignupModal: true });
  }

  switchToLogin() {
    this.setState({ showSignupModal: false, showForgotPasswordModal: false, showLoginModal: true });
  }

  toggleSidebar() {
    this.setState(prev => ({ sidebarOpen: !prev.sidebarOpen }));
  }

  closeSidebar() {
    this.setState({ sidebarOpen: false });
  }

  render() {
    // TODO: Replace cookie with API call to /api/v1/me
    const username = Cookies.get("username");

    return (
      <BrowserRouter>
        <div className="App">
          <ActionCableProvider url={this.state.cableUrl}>
            <NavBar
              loggedIn={this.state.loggedIn}
              username={username}
              onLoginClick={this.openLoginModal}
              onSignupClick={this.openSignupModal}
              onLogoutClick={this.openLogoutModal}
              onMenuClick={this.toggleSidebar}
              menuOpen={this.state.sidebarOpen}
            />
            <GamesLayout
              isAuthenticated={this.state.loggedIn}
              sidebarOpen={this.state.sidebarOpen}
              onCloseSidebar={this.closeSidebar}
            >
              <Switch>
                <Route
                  exact
                  path="/"
                  render={() => {
                    // Don't redirect if showing reset password modal (preserve URL with token)
                    if (this.state.showResetPasswordModal) {
                      return null;
                    }
                    return this.state.loggedIn ? <Redirect to="/games" /> : <Redirect to="/games/how-to-play" />;
                  }}
                />
                <Route path="/games" component={GamesRoutes} />
                <Route path="/users/:username" component={UserProfile} />
              </Switch>
            </GamesLayout>

            {this.state.showLoginModal && (
              <LoginModal
                onClose={this.closeModals}
                onLogin={() => this.setLogin(true)}
                onSwitchToSignup={this.switchToSignup}
                onForgotPassword={this.openForgotPasswordModal}
              />
            )}

            {this.state.showForgotPasswordModal && (
              <ForgotPasswordModal
                onClose={this.closeModals}
                onBackToLogin={this.switchToLogin}
              />
            )}

            {this.state.showResetPasswordModal && (
              <ResetPasswordModal
                resetToken={this.state.resetPasswordToken}
                onClose={this.closeModals}
                onSuccess={this.handlePasswordResetSuccess}
              />
            )}

            {this.state.showSignupModal && (
              <SignupModal
                onClose={this.closeModals}
                onLogin={() => this.setLogin(true)}
                onSwitchToLogin={this.switchToLogin}
              />
            )}

            {this.state.showLogoutModal && (
              <ConfirmationModal
                title="Logout"
                message="Are you sure you want to logout?"
                confirmText="Logout"
                cancelText="Cancel"
                onConfirm={this.handleLogout}
                onCancel={this.closeModals}
              />
            )}
          </ActionCableProvider>
        </div>
      </BrowserRouter>
    );
  }
}

export default App;
