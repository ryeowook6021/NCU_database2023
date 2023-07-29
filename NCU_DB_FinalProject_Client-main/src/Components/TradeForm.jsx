import React, { useRef, useState } from "react";
import { Card, Input, Button, Typography } from "@material-tailwind/react";
import axios from "axios";

const TradeForm = () => {
  const symbolRef = useRef();
  const shareRef = useRef();

  const dateRef = useRef();

  let [hint, setHint] = useState("");

  const Buy = async (e) => {
    e.preventDefault();
    let symbol = symbolRef.current.value.toString();
    let shares = parseFloat(shareRef.current.value);

    let date = dateRef.current.value;

    await axios
      .post("/recordTransaction", {
        date,
        buy_or_sell: 1,
        stock_code: symbol,
        shares,
      })
      .then((response) => {
        setHint(`買入成功`);
      })
      .catch((err) => {
        setHint(`買入時系統出現異常`);
      });

    symbolRef.current.value = "";
    shareRef.current.value = "";

    dateRef.current.value = "";
  };

  const Sell = async (e) => {
    e.preventDefault();
    let symbol = symbolRef.current.value.toString();
    let shares = parseFloat(shareRef.current.value);

    let date = dateRef.current.value;

    await axios
      .post("/recordTransaction", {
        date,
        buy_or_sell: -1,
        stock_code: symbol,
        shares,
      })
      .then((response) => {
        setHint("賣出成功");
      })
      .catch((error) => {
        setHint("賣出時系統出現異常");
      });

    symbolRef.current.value = "";
    shareRef.current.value = "";

    dateRef.current.value = "";
  };

  return (
    <Card color="transparent" shadow=" true" className=" border-2">
      {hint && (
        <Typography color=" gray" className="mt-3 mx-4">
          {hint}
        </Typography>
      )}
      <Typography variant="h4" color="blue-gray" className="mx-4 mt-3">
        一鍵交易
      </Typography>
      <Typography color="gray" className="mt-1 font-normal mx-4">
        填入你想要的交易資訊
      </Typography>
      <form action="" className="mt-8 mb-2 w-80 max-w-screen-lg sm:w-96 mx-4">
        <section className="mb-4 flex flex-col gap-6">
          <Input size="lg" label="交易標地物" inputRef={symbolRef} />
          <Input type="number" size="lg" label="數量" inputRef={shareRef} />

          <Input type="date" size="lg" label="日期" inputRef={dateRef} />
        </section>
        <div className="flex mt-4 mx-4 justify-center">
          <Button className="mx-4" color="green" onClick={Buy}>
            買入/做多
          </Button>
          <Button className="mx-4" color="red" onClick={Sell}>
            賣出/做空
          </Button>
        </div>
      </form>
    </Card>
  );
};

export default TradeForm;
