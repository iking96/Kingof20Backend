import React from "react";

import { BrowserRouter, Switch, Route } from "react-router-dom";
import Dashboard from "./Dashboard";

export default () => (
  <>
    <Switch>
      <Route exact path="/" component={Dashboard} />
    </Switch>
  </>
);
