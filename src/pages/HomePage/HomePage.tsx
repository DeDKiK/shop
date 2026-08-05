import ItemCard from "../../AppComponents/itemCard/itemCard";
import { useProducts } from "../../hooks/useProducts";
import styles from "./homePageStyle.module.css";

function HomePage() {
  const { items, loading, error } = useProducts();

  if (loading) return <p>Loading...</p>;
  if (error) return <p>{error}</p>;

  return (
    <div className={styles.itemsContainer}>
      {items.map((item) => (
        <ItemCard key={item.id} item={item} />
      ))}
    </div>
  );
}

export default HomePage;