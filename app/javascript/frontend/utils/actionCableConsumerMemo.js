import React, { Component } from "react";
import { ActionCableConsumer } from "react-actioncable-provider";

class ActionCableConsumerMemo extends Component {
  shouldComponentUpdate(nextProps, nextState) {
    return false;
  }

  render() {
    return <ActionCableConsumer {...this.props} />;
  }
}

export default ActionCableConsumerMemo;
