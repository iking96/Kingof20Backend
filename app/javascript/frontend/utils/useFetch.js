import React, { useEffect, useState } from "react";
import { getAccessToken } from "frontend/utils/authenticateHelper.js";

// Shamelessly stolen from Jeff
function useFetch(url, handleResponse) {
  const [isFetching, setIsFetching] = useState(false);
  const [hasFetched, setHasFetched] = useState(false);
  const [fetchError, setFetchError] = useState(null);

  const doFetch = async () => {
    setIsFetching(true);

    try {
      const opts = {
        headers: {
          AUTHORIZATION:
            `Bearer ${getAccessToken()}`
        }
      };
      const response = await fetch(url, opts);
      const json = await response.json();

      handleResponse({ response, json });
      setFetchError(null);
    } catch (e) {
      setFetchError(
        e.response
          ? { type: "Network Error", ...e.response }
          : { type: "Javascript Error", name: e.response, message: e.message }
      );
    }

    setIsFetching(false);
    setHasFetched(true);
  };

  return {
    isFetching,
    hasFetched,
    fetchError,
    doFetch
  };
}

export default useFetch;
