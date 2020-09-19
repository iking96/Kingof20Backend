export const boardSize = 12
export const rackSize = 7

const prod = {
  url: {
    API_URL: `https://kingof20.com:443`,
    API_WS_ROOT: `wss://kingof20.com:443/cable`
  }
};

const dev = {
  url: {
    API_URL: `http://localhost:3000`,
    API_WS_ROOT: `ws://localhost:3000/cable`
  }
};

export const config = process.env.NODE_ENV === "development" ? dev : prod;
