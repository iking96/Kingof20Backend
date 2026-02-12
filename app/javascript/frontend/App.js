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
import { isAuthenticated, getAccessToken } from "frontend/utils/authenticateHelper.js";
import { config } from "frontend/utils/constants.js";
import Cookies from "js-cookie";

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loggedIn: isAuthenticated(),
      showLoginModal: false,
      showSignupModal: false
    };
    this.setLogin = this.setLogin.bind(this);
    this.handleLogout = this.handleLogout.bind(this);
    this.openLoginModal = this.openLoginModal.bind(this);
    this.openSignupModal = this.openSignupModal.bind(this);
    this.closeModals = this.closeModals.bind(this);
    this.switchToSignup = this.switchToSignup.bind(this);
    this.switchToLogin = this.switchToLogin.bind(this);
  }

  setLogin(loginState) {
    this.setState({ loggedIn: loginState });
  }

  handleLogout() {
    Cookies.remove("access_token");
    Cookies.remove("username");
    this.setState({ loggedIn: false });
  }

  openLoginModal() {
    this.setState({ showLoginModal: true, showSignupModal: false });
  }

  openSignupModal() {
    this.setState({ showSignupModal: true, showLoginModal: false });
  }

  closeModals() {
    this.setState({ showLoginModal: false, showSignupModal: false });
  }

  switchToSignup() {
    this.setState({ showLoginModal: false, showSignupModal: true });
  }

  switchToLogin() {
    this.setState({ showSignupModal: false, showLoginModal: true });
  }

  render() {
    // TODO: Replace cookie with API call to /api/v1/me
    const username = Cookies.get("username");

    return (
      <ActionCableProvider url={`${config.url.API_WS_ROOT}?access_token=${getAccessToken()}`}>
        <BrowserRouter>
          <NavBar
            loggedIn={this.state.loggedIn}
            username={username}
            onLoginClick={this.openLoginModal}
            onSignupClick={this.openSignupModal}
            onLogoutClick={this.handleLogout}
          />
          <GamesLayout isAuthenticated={this.state.loggedIn}>
            <Switch>
              <Route
                exact
                path="/"
                render={() =>
                  this.state.loggedIn ? <Redirect to="/games" /> : <Redirect to="/games/how-to-play" />
                }
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
            />
          )}

          {this.state.showSignupModal && (
            <SignupModal
              onClose={this.closeModals}
              onLogin={() => this.setLogin(true)}
              onSwitchToLogin={this.switchToLogin}
            />
          )}
        </BrowserRouter>
      </ActionCableProvider>
    );
  }
}

export default App;
