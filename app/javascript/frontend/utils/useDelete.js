import React, { useCallback, useState } from "react";
import { getAccessToken } from "frontend/utils/authenticateHelper.js";

function useDelete(url, handleResponse = () => {}) {
  const [isDeleting, setIsDeleting] = useState(false);
  const [hasDeleted, setHasDeleted] = useState(false);
  const [deleteError, setDeleteError] = useState(null);

  const doDelete = async (id = 0) => {
    setIsDeleting(true);
    setHasDeleted(false);

    try {
      const opts = {
        headers: {
          AUTHORIZATION: `Bearer ${getAccessToken()}`,
          'Content-Type': "application/json",
          Accept: "application/json"
        },
        credentials: "same-origin",
        method: "DELETE"
      };

      const response = await fetch(url.concat(`/${id}`), opts);
      const json = await response.json();

      handleResponse({ response, json });
      setDeleteError(null);
    } catch (e) {
      setDeleteError(
        e.response
          ? { type: "Network Error", ...e.response }
          : { type: "Javascript Error", name: e.response, message: e.message }
      );
    }

    setIsDeleting(false);
    setHasDeleted(true);
  };

  return {
    isDeleting,
    hasDeleted,
    deleteError,
    doDelete
  };
}

export default useDelete;
