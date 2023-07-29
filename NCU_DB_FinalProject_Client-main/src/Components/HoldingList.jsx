import { List, ListItem, Card, Typography } from "@material-tailwind/react";

export default function TransactionList({ data }) {
  return (
    <Card className=" bg-yellow-100 max-w-min mx-10">
      <List className=" text-yellow-900">
        <ListItem className="flex justify-between">
          <Typography className="min-w-min">持有股票</Typography>
          <Typography className="min-w-min">持有股數</Typography>
        </ListItem>
        {data?.map((Holding) => (
          <ListItem className="flex justify-between">
            <Typography>{Holding.stock_code}</Typography>
            <Typography className=" mr-10">{Holding.shares}</Typography>
          </ListItem>
        ))}
      </List>
    </Card>
  );
}
