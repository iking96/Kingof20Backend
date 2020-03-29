import React from "react";

import { Link } from "react-router-dom";

class NavItem extends React.Component {
  render() {
    return (
      <li>
        <Link
          className={this.props.className}
          onClick={this.props.onclick}
          to={this.props.tolink}
        >
          {this.props.item}
        </Link>
      </li>
    );
  }
}
export default NavItem;
