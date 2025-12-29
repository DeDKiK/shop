import { BrowserRouter, Routes, Route } from "react-router-dom";
import Navbar from "./AppComponents/navbar/navbar";
import ItemCard from "./AppComponents/itemCard/itemCard";

function App() {
  return (
    <>
      <div>{Navbar()}</div>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<ItemCard />} />
        </Routes>
      </BrowserRouter>
    </>
  );
}

export default App;
