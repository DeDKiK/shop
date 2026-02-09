import { useParams } from "react-router-dom";
import { items } from "../../AppComponents/items";
import ItemCard from "../../AppComponents/itemCard/itemCard";

export default function categoryPage() {
  const { category } = useParams<{ category: string }>();

  const filteredItems = items.filter(
    (item) => item.category.toLowerCase() === category?.toLowerCase(),
  );

  console.log("Параметр з URL:", category);
  console.log("Всі категорії в масиві:");
  items.forEach((item) => {
    console.log(`- ${item.name} → "${item.category}"`);
  });
  console.log("Фільтровані товари:", filteredItems);

  return (
    <div>
      <h1>{category}</h1>

      {filteredItems.length === 0 ? (
        <p>No Items in this category</p>
      ) : (
        <div>
          {filteredItems.map((item) => (
            <ItemCard key={item.id} item={item} />
          ))}
        </div>
      )}
    </div>
  );
}
