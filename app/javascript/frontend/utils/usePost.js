import React, { useCallback, useState } from "react";
import { getAccessToken } from "frontend/utils/authenticateHelper.js";

function usePost(url, handleResponse) {
  const [isPosting, setIsPosting] = useState(false);
  const [hasPosted, setHasPosted] = useState(false);
  const [postError, setPostError] = useState(null);

  const doPost = useCallback(() => {
    const postData = async () => {
      setIsPosting(true);
      setHasPosted(false);

      try {
        const opts = {
          headers: {
            AUTHORIZATION: `Bearer ${getAccessToken()}`
          },
          credentials: 'same-origin',
          method: "POST"
        };
        const response = await fetch(url, opts);
        const json = await response.json();

        handleResponse({ response, json });
        setPostError(null);
      } catch (e) {
        setPostError(
          e.response
            ? { type: "Network Error", ...e.response }
            : { type: "Javascript Error", name: e.response, message: e.message }
        );
      }

      setIsPosting(false);
      setHasPosted(true);
    };

    postData();
  }, [url]);

  return {
    isPosting,
    hasPosted,
    postError,
    doPost
  };
}

export default usePost;
