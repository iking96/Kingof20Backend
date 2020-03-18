import React, { useEffect } from "react";
import Cookies from 'js-cookie';

function LoginForm(props) {
  return (
    <form onSubmit={props.handleSubmit} className="Login">
      <label>
        Email:
        <input
          type="username"
          name="username"
          placeholder="Username"
          value={props.username}
          onChange={props.handleChange}
          required
        />
      </label>
      <label>
        Password:
        <input
          type="password"
          name="password"
          placeholder="Password"
          value={props.password}
          onChange={props.handleChange}
          required
        />
      </label>
      <input type="submit" value="Login" />
    </form>
  );
}

class Login extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      username: "",
      password: "",
      token: ""
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.fetchToken = this.fetchToken.bind(this);
  }

  fetchToken = async () => {
    const { username, password } = this.state;

    try {
      const response = await fetch(
        `http://localhost:3000/oauth/token?username=${username}&password=${password}&grant_type=password`,
        { method: "POST" }
      );

      const json = await response.json();

      this.setState({ token: json.access_token });
      Cookies.set('access_token', json.access_token)

    } catch (error) {
      console.log(error);
      //return onError(error);
    }
  };

  handleSubmit(e) {
    e.preventDefault();

    this.fetchToken();
  }

  handleChange(e) {
    this.setState({
      [e.target.name]: e.target.value
    });
  }

  render() {
    return (
      <div>
        {this.state.token != "" ? (
          <h1>`{this.state.token}`</h1>
        ) : (
          <LoginForm
            handleSubmit={this.handleSubmit}
            handleChange={this.handleChange}
            username={this.state.username}
            password={this.state.password}
          />
        )}
      </div>
    );
  }
}
export default Login;
