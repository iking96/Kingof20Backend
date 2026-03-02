import { useState } from "react";
import { getAccessToken } from "frontend/utils/authenticateHelper.js";

function usePatch(url, handleResponse = () => {}) {
  const [isPatching, setIsPatching] = useState(false);
  const [hasPatched, setHasPatched] = useState(false);
  const [patchError, setPatchError] = useState(null);

  const doPatch = async (data = {}, onComplete = () => {}) => {
    setIsPatching(true);
    setHasPatched(false);

    try {
      const opts = {
        headers: {
          AUTHORIZATION: `Bearer ${getAccessToken()}`,
          'Content-Type': "application/json",
          Accept: "application/json"
        },
        credentials: "same-origin",
        method: "PATCH",
        body: JSON.stringify(data)
      };

      const response = await fetch(url, opts);
      const json = await response.json();

      handleResponse({ response, json });
      onComplete({ response, json });
      setPatchError(null);
    } catch (e) {
      setPatchError(
        e.response
          ? { type: "Network Error", ...e.response }
          : { type: "Javascript Error", name: e.response, message: e.message }
      );
    }

    setIsPatching(false);
    setHasPatched(true);
  };

  return {
    isPatching,
    hasPatched,
    patchError,
    doPatch
  };
}

export default usePatch;
