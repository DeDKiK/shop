import styles from "./LoginStyle.module.css";

function LoginPage() {
  return (
    <div className={styles.loginPage}>
      <div className={styles.loginTitle}>
        <h1>Login</h1>
      </div>

      <div className={styles.loginForm}>
        <form>
          <label htmlFor="username">
            Username:
            <input type="text" id="username" name="username" required />
          </label>
          <label htmlFor="password">
            Password:
            <input type="password" id="password" name="password" required />
          </label>
          {/* <button type="submit">Submit</button> */}
        </form>
      </div>
    </div>
  );
}

export default LoginPage;
