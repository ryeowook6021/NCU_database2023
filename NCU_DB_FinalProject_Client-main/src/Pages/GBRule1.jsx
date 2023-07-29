import React, { useEffect, useState } from "react";

const GBRule1 = () => {
  const [data, setdata] = useState("");

  // Using useEffect for single rendering
  useEffect(() => {
    // Using fetch to fetch the api from
    // flask server it will be redirected to proxy
    fetch("/plot-candle").then((res) =>
      res.json().then((data) => {
        // Setting a data from api
        setdata(data.img_data);
      })
    );
  }, []);
  const dataSource = `data:image/jpeg;base64,${data}`;
  return (
    <div className=" w-3/4 bg-slate">
      {data && <img src={dataSource} className=" lg:ml-72 lg:mt-9" />}
    </div>
  );
};

export default GBRule1;
