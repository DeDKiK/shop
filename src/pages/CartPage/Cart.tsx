import styles from "./CartStyle.module.css";
import { useCart } from "../../context/cartContext";

function CartPage() {
  const { items, deleteItem } = useCart();

  const total = items
    .reduce((sum, item) => {
      const price = parseFloat(item.price || "0");
      return sum + price * item.quantity;
    }, 0)
    .toFixed(2);

  return (
    <div className={styles.cartContainer}>
      <h1>Your Shopping Cart</h1>

      {items.length === 0 ? (
        <p>Your cart is empty.</p>
      ) : (
        <div className={styles.cartContent}>
          {/* left items */}
          <div className={styles.cartLeft}>
            {items.map((item) => (
              <div key={item.id} className={styles.cartItem}>
                <img src={item.src} alt={item.name} />
                <div className={styles.itemInfo}>
                  <p>
                    {item.name} x {item.quantity}
                  </p>
                  <p>${item.price}</p>
                  <button
                    className={styles.deleteBtn}
                    onClick={() => deleteItem(item.id)}
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>

          {/* right summary */}
          <div className={styles.cartRight}>
            <h2>Order Summary</h2>
            <p>Items: {items.length}</p>
            <p>
              Total: <strong>${total}</strong>
            </p>
            <button className={styles.checkoutBtn}>Proceed to Checkout</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default CartPage;
