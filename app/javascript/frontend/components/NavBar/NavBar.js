import React from "react"
import NavItem from "frontend/components/NavItem";

class NavBar extends React.Component {
  render () {
    return (
      <nav>
        <ul>
          <NavItem item="Home" tolink="/"></NavItem>
        </ul>
      </nav>
    );
  }
}
export default NavBar
