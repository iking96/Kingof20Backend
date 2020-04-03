import React, { useEffect, useState } from "react";

// Shamelessly stolen from Jeff
function useFetch(url, access_token, handleResponse) {
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
              `Bearer ${access_token}`
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
  }, [url]);

  return {
    isFetching,
    hasFetched,
    fetchError
  };
}

export default useFetch;
