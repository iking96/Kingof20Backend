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
    // Props not changed
    if (state.cable === props.cable && state.url === props.url) {
      return;
    }

    // cable is created by self, disconnect it
    if (state.cable) {
      state.cable.disconnect();
    }

    // create or assign cable
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
    var onReceived = this.props.onReceived;

    var onInitialized = this.props.onInitialized;

    var onConnected = this.props.onConnected;

    var onDisconnected = this.props.onDisconnected;

    var onRejected = this.props.onRejected;

    this.cable = this.props.cable.subscriptions.create(this.props.channel, {
      received: data => {
        onReceived && onReceived(data);
      },
      initialized: () => {
        onInitialized && onInitialized();
      },
      connected: () => {
        onConnected && onConnected();
      },
      disconnected: () => {
        onDisconnected && onDisconnected();
      },
      rejected: () => {
        onRejected && onRejected();
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
