import { BrowserRouter, Routes } from "react-router-dom";
import navbar from "./AppComponents/navbar/navbar";

function App() {
  return (
    <>
      <div>{navbar()}</div>
      <BrowserRouter>
        <Routes></Routes>
      </BrowserRouter>
    </>
  );
}

export default App;
