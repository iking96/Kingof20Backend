import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";
import "./App.css";

import { BrowserRouter, Switch, Route, Redirect } from "react-router-dom";
//Reference: https://github.com/cpunion/react-actioncable-provider/blob/master/lib/index.js
import { ActionCableProvider } from "frontend/utils/actionCableProvider";

import Games from "frontend/routes/Games";
import Login from "frontend/components/Login";
import Signup from "frontend/components/Signup";
import NavBar from "frontend/components/NavBar";
import { isAuthenticated, getAccessToken } from "frontend/utils/authenticateHelper.js";
import { config } from "frontend/utils/constants.js";
import Cookies from "js-cookie";

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loggedIn: isAuthenticated()
    };
    this.setLogin = this.setLogin.bind(this);
  }

  setLogin(loginState) {
    this.setState({ loggedIn: loginState });
  }

  render() {
    // TODO: Replace cookie with API call to /api/v1/me
    const username = Cookies.get("username");

    return (
      <ActionCableProvider url={`${config.url.API_WS_ROOT}?access_token=${getAccessToken()}`}>
        <BrowserRouter>
          <NavBar loggedIn={this.state.loggedIn} username={username} />
          <Switch>
            <Route
              exact
              path="/"
              render={() =>
                this.state.loggedIn ? <Redirect to="/games" /> : <Redirect to="/login" />
              }
            />
            <Route path="/games" render={() => <Games />} />
            <Route
              path="/login"
              render={() => <Login setLogin={this.setLogin} />}
            />
            <Route
              path="/signup"
              component={Signup}
            />
          </Switch>
        </BrowserRouter>
      </ActionCableProvider>
    );
  }
}

export default App;
