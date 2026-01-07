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
    { src: socksAsset, alt: "Socks", name: "Socks", id: "Socks" },
    { src: tShirtAsset, alt: "T-Shirt", name: "T-Shirt", id: "T-Shirt" },
    {
      src: bomberAsset,
      alt: "Bomber Jacket",
      name: "Bomber Jacket",
      id: "Bomber Jacket",
    },
    {
      src: simpleHatAsset,
      alt: "Simple Hat",
      name: "Simple Hat",
      id: "Simple Hat",
    },
    {
      src: fancyHatAsset,
      alt: "Fancy Hat",
      name: "Fancy Hat",
      id: "Fancy Hat",
    },
    { src: pantsAsset, alt: "Pants", name: "Pants", id: "Pants" },
    { src: sweaterAsset, alt: "Sweater", name: "Sweater", id: "Sweater" },
  ];
  return (
    <div className={styles.itemCard}>
      {items.map((item) => (
        <div key={item.id} className={styles.item}>
          <img src={item.src} alt={item.alt} />
          <p>{item.name}</p>
          <button
            onClick={() =>
              addToCart({
                id: item.id,
                name: item.name,
                src: item.src,
                quantity: 1,
              })
            }
          >
            Add to Cart
          </button>
        </div>
      ))}
    </div>
  );
}
export default ItemCard;
