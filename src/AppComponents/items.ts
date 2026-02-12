import socksAsset from "../assets/socks.jpeg";
import tShirtAsset from "../assets/Tshirt.jpg";
import bomberAsset from "../assets/bomber.jpg";
import simpleHatAsset from "../assets/simpleHat.jpg";
import fancyHatAsset from "../assets/fancyHat.jpg";
import pantsAsset from "../assets/pants.jpg";
import sweaterAsset from "../assets/sweater.jpg";
import IphoneAsset from "../assets/Apple-iPhone-17-hero-250909_inline.jpg.large.jpg";

export interface Item {
  src: string;
  alt: string;
  name: string;
  id: string;
  category: string;
  price: string;
}

export const items: Item[] = [
  {
    src: socksAsset,
    alt: "Socks",
    name: "Socks",
    id: "Socks",
    category: "Clothes",
    price: "5.99",
  },
  {
    src: tShirtAsset,
    alt: "T-Shirt",
    name: "T-Shirt",
    id: "T-Shirt",
    category: "Clothes",
    price: "13.99",
  },
  {
    src: bomberAsset,
    alt: "Bomber Jacket",
    name: "Bomber Jacket",
    id: "Bomber Jacket",
    category: "Clothes",
    price: "15.99",
  },
  {
    src: simpleHatAsset,
    alt: "Simple Hat",
    name: "Simple Hat",
    id: "Simple Hat",
    category: "Clothes",
    price: "19.99",
  },
  {
    src: fancyHatAsset,
    alt: "Fancy Hat",
    name: "Fancy Hat",
    id: "Fancy Hat",
    category: "Clothes",
    price: "8.99",
  },
  {
    src: pantsAsset,
    alt: "Pants",
    name: "Pants",
    id: "Pants",
    category: "Clothes",
    price: "6.99",
  },
  {
    src: sweaterAsset,
    alt: "Sweater",
    name: "Sweater",
    id: "Sweater",
    category: "Clothes",
    price: "4.99",
  },
  {
    src: IphoneAsset,
    alt: "Iphone",
    name: "Iphone 17",
    id: "Iphone 17",
    category: "Electronics",
    price: "59.99",
  },
];
