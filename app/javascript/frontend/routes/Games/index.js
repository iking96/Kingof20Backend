import React from "react";
import { Switch, Route } from "react-router-dom";
import GamesLayout from "./GamesLayout";
import List from "./List";
import Show from "./Show";

export default () => (
  <GamesLayout>
    <Switch>
      <Route exact path="/games" component={List} />
      <Route exact path="/games/:id" component={Show} />
    </Switch>
  </GamesLayout>
);
