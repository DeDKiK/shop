import { useEffect, useState } from "react";
import type { Item } from "../AppComponents/items";

interface Product {
  _id: string;
  name: string;
  description: string;
  price: number;
  category: string;
  image: string;
  stock: number;
}

export function useProducts() {
  const [items, setItems] = useState<Item[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await fetch("/api/products");
        
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        
        const products: Product[] = await response.json();
        
        const mappedItems: Item[] = products.map((p) => ({
          id: p._id,
          name: p.name,
          alt: p.name,
          src: p.image,
          category: p.category,
          price: String(p.price)
        }));
        
        setItems(mappedItems);
        } catch (err) {
            setError(err instanceof Error ? err.message : "Не вдалося завантажити товари");
        } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  return { items, loading, error };
}