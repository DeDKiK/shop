import { useSearchParams } from "react-router-dom";
import { items } from "../../AppComponents/items";
import ItemCard from "../../AppComponents/itemCard/itemCard";

function searchPage() {
  const [searchParams] = useSearchParams();
  const query = searchParams.get("q") || "";

  const decoded = decodeURIComponent(query);

  const foundItems = items.filter((i) =>
    i.name.toLowerCase().includes(decoded.toLowerCase()),
  );

  return (
    <div>
      <h2>Search Results for {decoded}</h2>

      <div>
        {foundItems.length === 0 ? (
          <p>No items found for "{decoded}"</p>
        ) : (
          foundItems.map((item) => <ItemCard key={item.id} item={item} />)
        )}
      </div>
    </div>
  );
}

export default searchPage;
