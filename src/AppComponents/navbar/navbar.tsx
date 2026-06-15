import React from "react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useCart } from "../../context/cartContext";
import { items } from "../../AppComponents/items";
import styles from "./navbarStyle.module.css";

function Navbar() {
  const [searchValue, setSearchValue] = useState("");
  const navigate = useNavigate();

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchValue.trim()) {
      navigate(`/search?q=${encodeURIComponent(searchValue.trim())}`);
      setSearchValue("");
    }
  };

  const { totalItems } = useCart();

  return (
    <div className={styles.navbar}>
      <div className={styles.navleft}>
        <Link to="/home" className={styles.navItem}>
          Home
        </Link>
        <div className={styles.dropdownCategory}>
          <button className={styles.navItem}>Categories</button>
          <div className={styles.dropdownContent}>
            <Link to="/category/electronics" className={styles.dropdownItem}>
              Electronics
            </Link>
            <Link to="/category/clothes" className={styles.dropdownItem}>
              Clothes
            </Link>
          </div>
        </div>
      </div>

      <div className={styles.navSearch}>
        <form className={styles.navSearchForm} onSubmit={handleSearch}>
          <input
            type="search"
            value={searchValue}
            onChange={(e) => setSearchValue(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") handleSearch(e);
            }}
          />
        </form>
      </div>

      <div className={styles.navRight}>
        <Link to="/cart" className={styles.navItem}>
          Cart
          {totalItems > 0 && (
            <span className={styles.cartBadge}>{totalItems}</span>
          )}
        </Link>

        <Link to="/login" className={styles.navItem}>
          Login
        </Link>
      </div>
    </div>
  );
}

export default Navbar;
