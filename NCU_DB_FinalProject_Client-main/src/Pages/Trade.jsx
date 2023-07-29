import React from "react";

import { TradingViewWidget, TradeForm } from "../Components";
import "../Styles/Trade.css";

import "../Styles/Trade.css";

const Trade = () => {
  return (
    <div className="flex TradeingViewWidget mt-8 justify-center">
      <TradingViewWidget />
      <div className=" mx-6 TradingBtn">
        <TradeForm />
      </div>
    </div>
  );
};

export default Trade;
