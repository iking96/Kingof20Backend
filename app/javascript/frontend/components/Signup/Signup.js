import React, { useEffect, useState } from "react";
import Cookies from "js-cookie";
import useField from "frontend/utils/useField";

import { Link } from "react-router-dom";

const SignupForm = ({ handleSubmit, username, password, email }) => {
  return (
    <form onSubmit={handleSubmit} id="Login">
      <label>
        Username:
        <input
          type="username"
          name="username"
          placeholder="Username"
          value={username.value}
          onChange={username.handleChange}
          required
        />
      </label>
      <label>
        Password:
        <input
          type="password"
          name="password"
          placeholder="Password"
          value={password.value}
          onChange={password.handleChange}
          required
        />
      </label>
      <label>
        Email:
        <input
          type="email"
          name="email"
          placeholder="Email (Optional)"
          value={email.value}
          onChange={email.handleChange}
        />
      </label>
      <input type="submit" value="Login" />
    </form>
  );
};

const Signup = ({ history }) => {
  const [errorString, setErrorString] = useState({ value: "" });
  const [accountCreated, setAccountCreated] = useState(false);
  const username = useField("");
  const password = useField("");
  const email = useField("");

  const submitSignup = async (username, password, email) => {
    try {
      const response = await fetch(
        `/api/v1/users?user[username]=${username}&user[password]=${password}&user[email]=${email}`,
        { method: "POST" }
      );

      const json = await response.json();
      var status = response.status;

      if (status == 200) {
        setAccountCreated(true);
      } else {
        setAccountCreated(false);
        setErrorString({ value: JSON.stringify(json.errors) });
      }
    } catch (error) {
      console.log("login error", error);
    }
  };

  const handleSubmit = e => {
    e.preventDefault();
    submitSignup(username.value, password.value, email.value);
  };

  var errorMessage;
  if (errorString.value) {
    errorMessage = <h1 align="center">{errorString.value}</h1>;
  } else {
    errorMessage = null;
  }

  if (accountCreated) {
    setTimeout(() => history.push(`/login`), 2000);
    return (
      <div>
        <h1 align="center">Account Creation Successful!</h1>
        <div align="center">You will be redirected shortly!</div>
      </div>
    );
  }

  return (
    <div>
      <div>
        <SignupForm
          handleSubmit={handleSubmit}
          username={username}
          password={password}
          email={email}
        />
        {errorMessage}
      </div>
    </div>
  );
};

export default Signup;
