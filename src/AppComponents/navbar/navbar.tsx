import { Link } from "react-router-dom";
import styles from "./navbarStyle.module.css";
import { useCart } from "../../context/cartContext";

function Navbar() {
  const { totalItems } = useCart();

  return (
    <div className={styles.navbar}>
      <div className={styles.navleft}>
        <Link to="/" className={styles.navItem}>
          Home
        </Link>
        <div className={styles.dropdownCategory}>
          <button className={styles.navItem}>Categories</button>
          <div className={styles.dropdownContent}>
            <Link to="/category/electronics" className={styles.dropdownItem}>
              Electronics
            </Link>
            <Link to="/category/jewelery" className={styles.dropdownItem}>
              Clothes
            </Link>
          </div>
        </div>
      </div>

      <div className={styles.navSearch}>
        <input type="search" />
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
