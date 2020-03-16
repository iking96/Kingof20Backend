import React from "react";

import { BrowserRouter, Switch, Route } from "react-router-dom";
import Login from "./Login";

export default () => (
  <>
    <Switch>
      <Route exact path="/" component={Login} />
    </Switch>
  </>
);
