import { Routes, Route } from "react-router-dom";
import Navbar from "./AppComponents/navbar/navbar";
import Home from "./pages/HomePage/HomePage";
import LoginPage from "./pages/LoginPage/Login";
import "./style.css";

function App() {
  return (
    <>
      <Navbar />

      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<LoginPage />} />
      </Routes>
    </>
  );
}

export default App;
