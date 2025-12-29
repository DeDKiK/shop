import styles from "./itemCardStyle.module.css";
import socksAsset from "../../assets/socks.jpeg";
import tShirtAsset from "../../assets/Tshirt.jpg";
import bomberAsset from "../../assets/bomber.jpg";
import simpleHatAsset from "../../assets/simpleHat.jpg";
import fancyHatAsset from "../../assets/fancyHat.jpg";
import pantsAsset from "../../assets/pants.jpg";
import sweaterAsset from "../../assets/sweater.jpg";

function ItemCard() {
  return (
    <>
      <div className={styles.itemCard}>
        <div className={styles.item}>
          <img src={socksAsset} alt="Socks" />
          <p>Socks</p>
        </div>
        <div className={styles.item}>
          <img src={tShirtAsset} alt="T-Shirt" />
          <p>T-Shirt</p>
        </div>
        <div className={styles.item}>
          <img src={bomberAsset} alt="Bomber Jacket" />
          <p>Bomber Jacket</p>
        </div>
        <div className={styles.item}>
          <img src={simpleHatAsset} alt="Simple Hat" />
          <p>Simple Hat</p>
        </div>
        <div className={styles.item}>
          <img src={fancyHatAsset} alt="Fancy Hat" />
          <p>Fancy Hat</p>
        </div>
        <div className={styles.item}>
          <img src={pantsAsset} alt="Pants" />
          <p>Pants</p>
        </div>
        <div className={styles.item}>
          <img src={sweaterAsset} alt="Sweater" />
          <p>Sweater</p>
        </div>
      </div>
    </>
  );
}
export default ItemCard;
