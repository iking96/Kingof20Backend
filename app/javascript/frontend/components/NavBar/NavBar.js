import React, { useEffect, useState } from "react";
import NavItem from "frontend/components/NavItem";
import { isAuthenticated } from "frontend/utils/authenticateHelper";

class NavBar extends React.Component {
  render() {
    return (
      <nav>
        <ul>
          <NavItem item="Home" tolink="/"></NavItem>
          <NavItem
            item="Games"
            tolink="/games"
            className={!this.props.loggedIn ? "disabled-link" : ""}
          ></NavItem>
          {!this.props.loggedIn == true ? (
            <NavItem
              item="Login"
              tolink="/login"
              className={"highlight"}
            ></NavItem>
          ) : (
            <NavItem
              item="Logout"
              tolink="/login"
              className={"highlight"}
            ></NavItem>
          )}
          {!this.props.loggedIn == true ? (
            <NavItem
              item="Signup"
              tolink="/signup"
              className={"highlight"}
            ></NavItem>
          ) : (
            <></>
          )}
        </ul>
      </nav>
    );
  }
}
export default NavBar;
