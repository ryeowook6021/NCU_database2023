import React, { useEffect, useRef } from "react";

let tvScriptLoadingPromise;

export default function TradingViewWidget() {
  const onLoadScriptRef = useRef();

  useEffect(() => {
    onLoadScriptRef.current = createWidget;

    if (!tvScriptLoadingPromise) {
      tvScriptLoadingPromise = new Promise((resolve) => {
        const script = document.createElement("script");
        script.id = "tradingview-widget-loading-script";
        script.src = "https://s3.tradingview.com/tv.js";
        script.type = "text/javascript";
        script.onload = resolve;

        document.head.appendChild(script);
      });
    }

    tvScriptLoadingPromise.then(
      () => onLoadScriptRef.current && onLoadScriptRef.current()
    );

    return () => (onLoadScriptRef.current = null);

    function createWidget() {
      if (
        document.getElementById("tradingview_6aab3") &&
        "TradingView" in window
      ) {
        new window.TradingView.widget({
          width: 920,
          height: 720,
          symbol: "BINANCE:BTCUSDT",
          interval: "D",
          timezone: "Asia/Taipei",
          theme: "light",
          style: "1",
          locale: "zh_TW",
          toolbar_bg: "#f1f3f6",
          enable_publishing: false,
          hide_side_toolbar: false,
          allow_symbol_change: true,
          watchlist: [
            "BINANCE:BTCUSDT",
            "NASDAQ:META",
            "NASDAQ:AAPL",
            "NASDAQ:TSLA",
            "NASDAQ:GOOG",
          ],
          container_id: "tradingview_6aab3",
        });
      }
    }
  }, []);

  return (
    <div className="tradingview-widget-container">
      <div id="tradingview_6aab3" />
    </div>
  );
}
