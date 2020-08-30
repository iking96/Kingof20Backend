import React, { useEffect, useState } from "react";
import useFetch from "frontend/utils/useFetch";

let responseJsons = {};
let responses = [];

const updateCombinedJson = ({ response, json }) => {
  Object.keys(json).forEach(function(key) {
    responseJsons[key] = json[key];
  });
  responses.push(response);
};

// Shamelessly stolen from Jeff
function useMultiFetch(urls, handleResponse) {
  const [isFetching, setIsFetching] = useState(false);
  const [hasFetched, setHasFetched] = useState(false);
  const [fetchError, setFetchError] = useState(null);

  const fetchUtils = urls.map(url => useFetch(url, updateCombinedJson));

  const doFetch = async () => {
    setIsFetching(true);
    responseJsons = {};

    try {
      await Promise.all(fetchUtils.map(fetcher => fetcher.doFetch()));

      var json = responseJsons;
      handleResponse({ responses, json });
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

export default useMultiFetch;
