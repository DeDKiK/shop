import styles from "./itemCardStyle.module.css";
import { useCart } from "../../context/cartContext";

interface Item {
  id: string;
  name: string;
  src: string;
  alt: string;
  price: string;
}

interface IitemCardProps {
  item: Item;
}

function ItemCard({ item }: IitemCardProps) {
  const { addToCart } = useCart();
  return (
    <div key={item.id} className={styles.item}>
      <img src={item.src} alt={item.alt} />
      <p>
        {item.name} - {item.price}$
      </p>
      <button
        onClick={() =>
          addToCart({
            id: item.id,
            name: item.name,
            src: item.src,
            quantity: 1,
            price: item.price,
          })
        }
      >
        Add to Cart
      </button>
    </div>
  );
}
export default ItemCard;
