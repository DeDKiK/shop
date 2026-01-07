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
        <ul>
          {items.map((item, index) => (
            <li key={item.id}>
              {item.name} - {item.quantity}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default CartPage;
