import { Link } from "react-router-dom";
import styles from "./navbarStyle.module.css";

function Navbar() {
  return (
    <div className={styles.navbar}>
      <div className={styles.navleft}>
        <Link to="/" className={styles.navItem}>
          Home
        </Link>
        <Link to="/" className={styles.navItem}>
          Category
        </Link>
      </div>

      <div className={styles.navSearch}>
        <input type="search" />
      </div>

      <div className={styles.navRight}>
        <Link to="/" className={styles.navItem}>
          Cart
        </Link>

        <Link to="/login" className={styles.navItem}>
          Login
        </Link>
      </div>
    </div>
  );
}

export default Navbar;
