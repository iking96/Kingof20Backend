import React from "react";
import { Switch, Route } from "react-router-dom";
import GamesLayout from "./GamesLayout";
import GamesRedirect from "./GamesRedirect";
import Show from "./Show";
import HowToPlay from "frontend/routes/HowToPlay";

export default ({ isAuthenticated }) => (
  <GamesLayout isAuthenticated={isAuthenticated}>
    <Switch>
      <Route exact path="/games" component={GamesRedirect} />
      <Route exact path="/games/how-to-play" component={HowToPlay} />
      <Route exact path="/games/:id" component={Show} />
    </Switch>
  </GamesLayout>
);
