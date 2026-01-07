import styles from "./CartStyle.module.css";
import { useCart } from "../../context/cartContext";

function CartPage() {
  const { items } = useCart();
  return (
    <div>
      <h1>Your Shopping Cart</h1>
      {/* Cart items will be displayed here */}

      {items.length === 0 ? (
        <p>Your cart is empty.</p>
      ) : (
        <div className={styles.cartCard}>
          {items.map((item) => (
            <div className={styles.cartItem}>
              <img src={item.src} alt={item.name} />
              <p key={item.id}>
                {item.name} - {item.quantity}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default CartPage;
