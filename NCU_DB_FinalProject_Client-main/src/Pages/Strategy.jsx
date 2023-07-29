import React, { useRef, useState } from "react";
import {
  Input,
  Button,
  Card,
  Typography,
  List,
  ListItem,
} from "@material-tailwind/react";
import axios from "axios";

const Strategy = () => {
  const dateRef = useRef();
  let stock = [];
  const [stocks, setStocks] = useState([]);

  const Search = async (e) => {
    e.preventDefault();

    let date = dateRef.current.value;
    dateRef.current.value = "";
    await axios
      .post("/get_stock", {
        date,
      })
      .then((response) => {
        stock = response.data.data;
        stock?.forEach((element) => {
          if (element.Buy_or_sell == 1) element.Buy_or_sell = "買";
          else if (element.Buy_or_sell == -1) element.Buy_or_sell = "賣";
          else element.Buy_or_sell = "";
        });
        console.log(stock);
      })
      .catch((err) => {
        // setHint(`買入時系統出現異常`);
        console.log(err);
      });

    setStocks(stock);
  };

  return (
    <section className="flex items-center flex-col">
      <form action="" className="mt-20 mb-2 w-80 max-w-screen-lg sm:w-96 mx-4">
        <Input size="lg" label="欲查詢日期" inputRef={dateRef} />
        <Button
          className=" max-w-screen-lg w-80 sm:w-96 mt-5"
          color="yellow"
          onClick={Search}
        >
          查詢
        </Button>

        <Card className=" mt-5">
          <List className=" ">
            <ListItem className="flex justify-between">
              <Typography className="min-w-min">交易股票</Typography>
              <Typography className="min-w-min ml-9">買/賣</Typography>
            </ListItem>
            {stocks?.map((Stock) => (
              <ListItem className="flex justify-between">
                <Typography>{Stock.Company}</Typography>
                <Typography>{Stock.Buy_or_sell}</Typography>
              </ListItem>
            ))}
          </List>
        </Card>
      </form>
    </section>
  );
};

export default Strategy;
