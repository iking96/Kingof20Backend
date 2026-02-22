// From: https://github.com/cpunion/react-actioncable-provider/blob/master/lib/index.js
import React, { Component } from "react";
var PropTypes = require("prop-types");
var actioncable = require("actioncable");
var { Provider, Consumer } = React.createContext();

class ActionCableProvider extends Component {
  state = {
    cable: null,
    url: null
  };

  componentWillUnmount() {
    if (this.state.cable) {
      this.state.cable.disconnect();
    }
  }

  static getDerivedStateFromProps(props, state) {
    // If using url prop and it hasn't changed, keep existing cable
    if (!props.cable && state.url === props.url && state.cable) {
      return null;
    }

    // If using cable prop and it hasn't changed, keep it
    if (props.cable && state.cable === props.cable) {
      return null;
    }

    // Disconnect existing cable if we created it (not passed via props)
    if (state.cable && !props.cable) {
      state.cable.disconnect();
    }

    return {
      cable: props.cable || actioncable.createConsumer(props.url),
      url: props.url
    };
  }

  render() {
    return React.createElement(
      Provider,
      {
        value: {
          cable: this.state.cable
        }
      },
      this.props.children || null
    );
  }
}

class ActionCableController extends Component {
  componentDidMount() {
    // Use arrow functions to always access current props (avoids stale closures)
    this.cable = this.props.cable.subscriptions.create(this.props.channel, {
      received: data => {
        this.props.onReceived && this.props.onReceived(data);
      },
      initialized: () => {
        this.props.onInitialized && this.props.onInitialized();
      },
      connected: () => {
        this.props.onConnected && this.props.onConnected();
      },
      disconnected: () => {
        this.props.onDisconnected && this.props.onDisconnected();
      },
      rejected: () => {
        this.props.onRejected && this.props.onRejected();
      }
    });
  }

  componentWillUnmount() {
    if (this.cable) {
      this.props.cable.subscriptions.remove(this.cable);
      this.cable = null;
    }
  }

  send(data) {
    if (!this.cable) {
      throw new Error("ActionCable component unloaded");
    }

    this.cable.send(data);
  }

  perform() {
    if (!this.cable) {
      throw new Error("ActionCable component unloaded");
    }

    this.cable.perform(data);
  }

  render() {
    return this.props.children || null;
  }
};

class ActionCableConsumer extends Component {
  render() {
    return (
      <Consumer>
        {({ cable }) => (
          <ActionCableController
            {...this.props}
            cable={cable}
          >
            {this.props.children || null}
          </ActionCableController>
        )}
      </Consumer>
    );
  }
}

export { ActionCableProvider, ActionCableController, ActionCableConsumer };
