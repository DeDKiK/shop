import { useParams } from "react-router-dom";
import { items } from "../../AppComponents/items";
import ItemCard from "../../AppComponents/itemCard/itemCard";
import styles from "../HomePage/homePageStyle.module.css";

export default function CategoryPage() {
  const { category } = useParams<{ category: string }>();

  const filteredItems = items.filter(
    (item) => item.category.toLowerCase() === category?.toLowerCase(),
  );

  return (
    <div>
      <h1>{category}</h1>

      {filteredItems.length === 0 ? (
        <p>No Items in {category}</p>
      ) : (
        <div className={styles.itemsContainer}>
          {filteredItems.map((item) => (
            <ItemCard key={item.id} item={item} />
          ))}
        </div>
      )}
    </div>
  );
}
