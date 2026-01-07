import { createContext, useContext, useState, type ReactNode } from "react";

interface CartItem {
  id: number | string;
  name: string;
  quantity: number;
  src: string;
}

interface CartContextType {
  items: CartItem[];
  totalItems: number;
  addToCart: (item: CartItem) => void;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

export function CartProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<CartItem[]>([]);

  const totalItems = items.reduce((acc, item) => acc + item.quantity, 0);

  const addToCart = (item: CartItem) => {
    if (items.find((i) => i.id === item.id)) {
      setItems(
        items.map((i) =>
          i.id == item.id ? { ...i, quantity: i.quantity + 1 } : i
        )
      );
    } else {
      setItems((prevItems) => [...prevItems, item]);
    }
  };

  return (
    <CartContext.Provider value={{ items, totalItems, addToCart }}>
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  const context = useContext(CartContext);
  if (!context) {
    throw new Error("useCart must be used within a CartProvider");
  }
  return context;
}
