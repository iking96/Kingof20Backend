export const boardSize = 12
export const rackSize = 7

const prod = {
  url: {
    API_URL: `http://54.69.119.37:3000`
  }
};

const dev = {
  url: {
    API_URL: `http://localhost:3000`
  }
};

export const config = process.env.NODE_ENV === "development" ? dev : prod;
