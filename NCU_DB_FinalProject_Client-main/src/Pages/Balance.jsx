import React, { useState, useEffect } from "react";
import { TransactionList, HoldingList } from "../Components";
import axios from "axios";

const Balance = () => {
  const [holdings, setHoldings] = useState();
  const [transaction, setTransaction] = useState();

  const delay = () => {
    return new Promise((resolve) => setTimeout(resolve, 2000));
  };

  useEffect(() => {
    async function fetchHoldings_and_transactions() {
      await axios
        .get("/holding_stock")
        .then((res) => {
          setHoldings(res.data.data);
        })
        .catch((err) => {
          console.log(err);
        });
      delay();
      await axios
        .get("/Transaction")
        .then((res) => {
          let transactions = res.data.data;

          transactions?.forEach((element) => {
            if (element.Buy_or_sell == 1) element.Buy_or_sell = "買";
            else if (element.Buy_or_sell == -1) element.Buy_or_sell = "賣";
            else element.Buy_or_sell = "";

            element.Stock_price = parseFloat(element.Stock_price)
              ? parseFloat(element.Stock_price).toFixed(2)
              : "";
          });
          setTransaction(transactions);
        })
        .catch((err) => {
          console.log(err);
        });
    }

    fetchHoldings_and_transactions();
  }, []);

  return (
    <section className=" flex justify-center mt-4">
      <TransactionList data={transaction} />
      <HoldingList data={holdings} />
    </section>
  );
};

export default Balance;
