export const boardSize = 12
export const rackSize = 7
export const swapPassPenalty = 6

const prod = {
  url: {
    API_URL: `https://app:443`, // Seemingly unused
    API_WS_ROOT: `/cable`
  }
};

const dev = {
  url: {
    API_URL: `http://localhost:3000`, // Seemingly unused
    API_WS_ROOT: `/cable`
  }
};

export const config = process.env.NODE_ENV === "development" ? dev : prod;
export const CLIENT_ID = process.env.REACT_APP_CLIENT_ID;