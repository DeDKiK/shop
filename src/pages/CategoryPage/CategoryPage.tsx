import { useParams } from "react-router-dom";
import { useProducts } from "../../hooks/useProducts";
import ItemCard from "../../AppComponents/itemCard/itemCard";
import styles from "../HomePage/homePageStyle.module.css";

export default function CategoryPage() {
  const { category } = useParams<{ category: string }>();
  const { items, loading, error } = useProducts();

  if (loading) return <p>Loading...</p>;
  if (error) return <p>{error}</p>;

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