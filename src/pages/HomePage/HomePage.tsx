import ItemCard from "../../AppComponents/itemCard/itemCard";
import { items } from "../../AppComponents/items";
import styles from "./homePageStyle.module.css";

function HomePage() {
  return (
    <div className={styles.itemsContainer}>
      {items.map((item) => (
        <ItemCard key={item.id} item={item} />
      ))}
    </div>
  );
}

export default HomePage;
