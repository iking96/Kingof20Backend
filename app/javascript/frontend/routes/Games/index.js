import React from "react";

import { BrowserRouter, Switch, Route } from "react-router-dom";
import List from "./List";
import Show from "./Show";
import TileDistribution from "./TileDistribution";
import MoveHistory from "./MoveHistory";

export default () => (
  <>
    <Switch>
      <Route exact path="/games" component={List} />
      <Route exact path="/games/:id" component={Show} />
      <Route exact path="/games/:id/tile_distribution" component={TileDistribution} />
      <Route exact path="/games/:id/move_history" component={MoveHistory} />
    </Switch>
  </>
);
