import styles from "./navbarStyle.module.css";

function navbar() {
  return (
    <div className={styles.navbar}>
      <div className={styles.navleft}>
        <button>Home</button>
        <button>Category</button>
      </div>

      <div className={styles.navSearch}>
        <input type="search" name="" id=""></input>
      </div>

      <div className={styles.navRight}>
        <button>Cart</button>
        <button>Login</button>
      </div>
    </div>
  );
}

export default navbar;
