import React, { useEffect, useState } from "react";
import Cookies from "js-cookie";
import useField from "frontend/utils/useField";

import { Link } from "react-router-dom";

const LoginForm = props => {
  return (
    <form onSubmit={props.handleSubmit} id="Login">
      <label>
        Username:
        <input
          type="username"
          name="username"
          placeholder="Username"
          value={props.username.value}
          onChange={props.username.handleChange}
          required
        />
      </label>
      <label>
        Password:
        <input
          type="password"
          name="password"
          placeholder="Password"
          value={props.password.value}
          onChange={props.password.handleChange}
          required
        />
      </label>
      <input type="submit" value="Login" />
    </form>
  );
};

const LoggedInMessage = props => {
  return (
    <div id="Logout">
      <h1 align="center">You are logged in!</h1>
      <button onClick={props.onClick}>Log Out</button>
    </div>
  );
};

const Login = ({ setLogin }) => {
  const [token, setToken] = useState({ value: "" });
  const [errorString, setErrorString] = useState({ value: "" });
  const username = useField("");
  const password = useField("");

  const fetchToken = async (username, password) => {
    try {
      const response = await fetch(
        `/oauth/token?username=${username}&password=${password}&grant_type=password`,
        { method: "POST" }
      );

      const json = await response.json();

      if (response.status == 200) {
        setToken({ value: json.access_token });
        Cookies.set("access_token", json.access_token);
        setLogin(true);
      } else {
        setErrorString({ value: json.status_code + " " + json.message });
      }
    } catch (error) {
      console.log("login error", error);
    }
  };

  const handleSubmit = e => {
    e.preventDefault();
    fetchToken(username.value, password.value);
  };

  const handleLogout = e => {
    e.preventDefault();
    setToken({ value: "" });
    Cookies.remove("access_token");
    setLogin(false);
  };

  var errorMessage;
  if (errorString.value) {
    errorMessage = <h1 align="center">{errorString.value}</h1>;
  } else {
    errorMessage = null;
  }

  useEffect(() => {
    const access_token = Cookies.get("access_token");
    if (access_token) {
      setToken({ value: access_token });
    }
  }, []);

  return (
    <div>
      {token.value ? (
        <LoggedInMessage onClick={handleLogout} />
      ) : (
        <div>
          <LoginForm
            handleSubmit={handleSubmit}
            username={username}
            password={password}
          />
          <div align="center">
            No account? <Link to={`/signup`}> Signup here! </Link>
          </div>
          {errorMessage}
        </div>
      )}
    </div>
  );
};

export default Login;
