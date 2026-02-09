import { Routes, Route } from "react-router-dom";
import Navbar from "./AppComponents/navbar/navbar";
import Home from "./pages/HomePage/HomePage";
import LoginPage from "./pages/LoginPage/Login";
import CartPage from "./pages/CartPage/Cart";
import CategoryPage from "./pages/CategoryPage/categoryPage";
import "./style.css";

function App() {
  return (
    <>
      <Navbar />

      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/category/:category" element={<CategoryPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/cart" element={<CartPage />} />
      </Routes>
    </>
  );
}

export default App;
