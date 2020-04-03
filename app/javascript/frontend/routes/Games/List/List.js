import React, { useEffect, useState } from "react";

import useFetch from "frontend/utils/useFetch";
import {
  isAuthenticated,
  getAccessToken
} from "frontend/utils/authenticateHelper.js";

const renderResultRows = data => {
    return data.map(songObj =>
      <RowComponent
        key={songObj.id}
        data={songObj}
        onClick={this.fetchDetails}
      />
    )
  }

const List = () => {
  const [data, setData] = useState({});
  const access_token = getAccessToken();
  const is_authenticated = isAuthenticated();

  useEffect(() => {
    if (!is_authenticated) {
      window.location.replace(`/`);
    }
  }, [is_authenticated]);

  const { isFetching, hasFetched, fetchError } = useFetch(
    "/api/v1/games",
    access_token,
    ({ json }) => {
      setData({ json });
    }
  );

  return (
    <div>
      <table>
        <thead></thead>
        <tbody>{JSON.stringify(data)}</tbody>
      </table>
    </div>
  );
};

export default List;
