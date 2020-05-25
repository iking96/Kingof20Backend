import React, { useEffect, useState } from "react";
import { getAccessToken } from "frontend/utils/authenticateHelper.js";

// Shamelessly stolen from Jeff
function useFetch(url, reFetch, handleResponse) {
  const [isFetching, setIsFetching] = useState(false);
  const [hasFetched, setHasFetched] = useState(false);
  const [fetchError, setFetchError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
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

    fetchData();
  }, [url, reFetch]);

  return {
    isFetching,
    hasFetched,
    fetchError
  };
}

export default useFetch;
