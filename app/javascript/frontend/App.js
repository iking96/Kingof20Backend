import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";
import "./App.css";

import { BrowserRouter, Switch, Route } from "react-router-dom";

import Games from "frontend/routes/Games";
import Login from "frontend/components/Login";
import Home from "frontend/routes/Home";
import Navbar from "frontend/components/NavBar";
import { isAuthenticated } from "frontend/utils/authenticateHelper.js";

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loggedIn: isAuthenticated()
    };
    this.setLogin = this.setLogin.bind(this);
  }

  setLogin(loginState) {
      this.setState({loggedIn: loginState});
  }

  render() {
    return (
      <BrowserRouter>
        <Navbar loggedIn={this.state.loggedIn}/>
        <Switch>
          <Route exact path="/" render={() => <Home />} />
          <Route exact path="/games" render={() => <Games />} />
          <Route exact path="/login" render={() => <Login setLogin={this.setLogin}/>} />
        </Switch>
      </BrowserRouter>
    );
  }
}

export default App;
