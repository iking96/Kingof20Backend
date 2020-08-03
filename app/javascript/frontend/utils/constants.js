export const boardSize = 12
export const rackSize = 7

const prod = {
  url: {
    API_URL: `http://54.69.119.37:3000`,
    API_WS_ROOT: `ws://54.69.119.37:3000/cable`
  }
};

const dev = {
  url: {
    API_URL: `http://localhost:3000`,
    API_WS_ROOT: `ws://localhost:3000/cable`
  }
};

export const config = process.env.NODE_ENV === "development" ? dev : prod;
