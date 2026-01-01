import styles from "./itemCardStyle.module.css";
import socksAsset from "../../assets/socks.jpeg";
import tShirtAsset from "../../assets/Tshirt.jpg";
import bomberAsset from "../../assets/bomber.jpg";
import simpleHatAsset from "../../assets/simpleHat.jpg";
import fancyHatAsset from "../../assets/fancyHat.jpg";
import pantsAsset from "../../assets/pants.jpg";
import sweaterAsset from "../../assets/sweater.jpg";
import { useCart } from "../../context/cartContext";

function ItemCard() {
  const { addToCart } = useCart();
  const items = [
    { src: socksAsset, alt: "Socks", name: "Socks" },
    { src: tShirtAsset, alt: "T-Shirt", name: "T-Shirt" },
    { src: bomberAsset, alt: "Bomber Jacket", name: "Bomber Jacket" },
    { src: simpleHatAsset, alt: "Simple Hat", name: "Simple Hat" },
    { src: fancyHatAsset, alt: "Fancy Hat", name: "Fancy Hat" },
    { src: pantsAsset, alt: "Pants", name: "Pants" },
    { src: sweaterAsset, alt: "Sweater", name: "Sweater" },
  ];
  return (
    <div className={styles.itemCard}>
      {items.map((item) => (
        <div key={item.alt} className={styles.item}>
          <img src={item.src} alt={item.alt} />
          <p>{item.name}</p>
          <button onClick={addToCart}>Add to Cart</button>
        </div>
      ))}
    </div>
  );
}
export default ItemCard;
