import React from "react";

import { BrowserRouter, Switch, Route } from "react-router-dom";
import List from "./List";

export default () => (
  <>
    <Switch>
      <Route exact path="/games" component={List} />
    </Switch>
  </>
);
