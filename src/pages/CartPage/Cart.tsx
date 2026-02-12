import styles from "./CartStyle.module.css";
import { useCart } from "../../context/cartContext";

function CartPage() {
  const { items, deleteItem } = useCart();
  return (
    <div>
      <h1>Your Shopping Cart</h1>

      {items.length === 0 ? (
        <p>Your cart is empty.</p>
      ) : (
        <div className={styles.cartCard}>
          {items.map((item) => (
            <div key={item.id} className={styles.cartItem}>
              <img src={item.src} alt={item.name} />
              <p>
                {item.name} - {item.quantity}
              </p>
              <button onClick={() => deleteItem(item.id)}>Delete</button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default CartPage;
