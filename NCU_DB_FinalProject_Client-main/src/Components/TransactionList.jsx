import { List, ListItem, Card, Typography } from "@material-tailwind/react";
import "../Styles/TransactionList.css";

export default function TransactionList({ data }) {
  return (
    <Card className="TransactionList bg-blue-100 mx-10">
      <List className=" text-blue-900">
        <ListItem className="flex justify-between">
          <Typography className="min-w-min">成交日期</Typography>
          <Typography className="min-w-min ml-9">買/賣</Typography>
          <Typography className="min-w-min">成交股票</Typography>
          <Typography className="min-w-min">成交金額</Typography>
          <Typography className="min-w-min">成交股數</Typography>
          <Typography className="min-w-min">帳戶餘額</Typography>
        </ListItem>
        {data?.map((Transaction) => (
          <ListItem className="flex justify-between">
            <Typography>{Transaction.Date}</Typography>
            <Typography>{Transaction.Buy_or_sell}</Typography>
            <Typography>{Transaction.Stock_code}</Typography>
            <Typography>{Transaction.Stock_price}</Typography>
            <Typography>{Transaction.Shares}</Typography>
            <Typography>{Transaction.Remain_cash}</Typography>
          </ListItem>
        ))}
      </List>
    </Card>
  );
}
