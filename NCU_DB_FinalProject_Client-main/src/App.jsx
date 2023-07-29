import "./Styles/App.css";
import { Nav } from "./Components";
import {
  Trade,
  Home,
  Deposit,
  GBRule1,
  Aboutus,
  Balance,
  Strategy,
  Simulate,
} from "./Pages";
import { Routes, Route } from "react-router-dom";

function App() {
  return (
    <main className="App flex flex-col bg-white">
      <Nav />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/Trade" element={<Trade />} />
        <Route path="/Strategy" element={<Strategy />} />
        <Route path="/Simulate" element={<Simulate />} />
        <Route path="/Deposit/" element={<Deposit />} />
        <Route path="/Balance/" element={<Balance />} />
        <Route path="/About/" element={<Aboutus />} />
      </Routes>
    </main>
  );
}

export default App;
