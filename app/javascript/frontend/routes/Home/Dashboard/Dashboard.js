import React from "react";
import logo from "frontend/assets/logo-large.png";

const Dashboard = () => {
  return (
    <div style={{textAlign: 'center', padding:'10px'}}>
      <img
        src={logo}
        alt="Logo"
        style={{
          width: "200px",
          height: "200px",
          display: 'block',
          margin: 'auto',
          padding:'10px'
        }}
      />
      King of 20! Test Site
    </div>
  );
};

export default Dashboard;
