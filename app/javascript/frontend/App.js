import React from "react";
import PropTypes from "prop-types";
import "./App.css";

import { BrowserRouter, Switch, Route } from "react-router-dom";

import Home from "frontend/routes/Home";
import Navbar from "frontend/components/NavBar";

class App extends React.Component {
  render() {
    return (
      <BrowserRouter>
        <Navbar />
        <Switch>
          <Route exact path="/" render={() => <Home />} />
        </Switch>
      </BrowserRouter>
    );
  }
}

export default App;
