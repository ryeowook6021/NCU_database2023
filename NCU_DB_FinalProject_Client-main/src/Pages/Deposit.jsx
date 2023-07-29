import React, { useRef, useState } from "react";
import axios from "axios";
import { Card, Input, Button, Typography } from "@material-tailwind/react";

const Account = () => {
  const amountRef = useRef();
  const dateRef = useRef();

  const [hint, setHint] = useState("");

  const InitialAccount = async (e) => {
    e.preventDefault();
    let date = dateRef.current.value;
    let deposit = amountRef.current.value;
    await axios
      .post("/initial_account", {
        date,
        deposit,
      })
      .then((res) => {
        setHint("初始化成功");
      })
      .catch((err) => {
        setHint("初始化時系統出現異常");
      });

    dateRef.current.value = "";
    amountRef.current.value = "";
  };

  return (
    <section className=" flex justify-center mt-8">
      <Card className=" w-96">
        {hint && (
          <Typography color="gray" className="mx-4 mt-3">
            {hint}
          </Typography>
        )}
        <Typography variant="h4" color="blue-gray" className="mx-4 mt-3">
          初始化您的資金
        </Typography>
        <Typography color="gray" className="mt-1 mx-4">
          Enter Details for your virtual account
        </Typography>
        <form>
          <section className=" mx-4 my-4 flex flex-col gap-3">
            <Input
              size="lg"
              label="Amount_money"
              type="number"
              inputRef={amountRef}
            />
            <Input size="lg" label="Date" type="date" inputRef={dateRef} />
          </section>
          <Button className="my-6 mx-4" color="yellow" onClick={InitialAccount}>
            Initial
          </Button>
        </form>
      </Card>
    </section>
  );
};

export default Account;
