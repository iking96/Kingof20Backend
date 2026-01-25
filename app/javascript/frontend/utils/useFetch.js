import React, { useEffect, useState, useCallback, useRef } from "react";
import { getAccessToken } from "frontend/utils/authenticateHelper.js";

// Shamelessly stolen from Jeff
function useFetch(url, handleResponse) {
  const [isFetching, setIsFetching] = useState(false);
  const [hasFetched, setHasFetched] = useState(false);
  const [fetchError, setFetchError] = useState(null);

  // Use refs to always have the latest values in the callback
  const urlRef = useRef(url);
  const handleResponseRef = useRef(handleResponse);

  // Update refs when values change
  useEffect(() => {
    urlRef.current = url;
    handleResponseRef.current = handleResponse;
  }, [url, handleResponse]);

  const doFetch = useCallback(async () => {
    setIsFetching(true);

    try {
      const opts = {
        headers: {
          AUTHORIZATION:
            `Bearer ${getAccessToken()}`
        }
      };
      const response = await fetch(urlRef.current, opts);
      const json = await response.json();

      handleResponseRef.current({ response, json });
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
  }, []);

  return {
    isFetching,
    hasFetched,
    fetchError,
    doFetch
  };
}

export default useFetch;
