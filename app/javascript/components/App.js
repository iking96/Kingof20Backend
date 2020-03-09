import React from "react"
import PropTypes from "prop-types"

import { BrowserRouter, Switch, Route } from 'react-router-dom'

import HelloWorld from './HelloWorld'

class App extends React.Component {
  render () {
    return (
      <BrowserRouter>
        <Switch>
          <Route exact path="/" render={() => ("King of 20!")} />
          <Route path="/hello" render={() => <HelloWorld greeting="pinapple"/>} />
        </Switch>
      </BrowserRouter>
    );
  }
}

export default App
