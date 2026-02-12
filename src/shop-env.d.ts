declare module "*.module.css" {
  const classes: { [key: string]: string };
  export default classes;
}

declare module "*.module.scss" {
  const classes: { [key: string]: string };
  export default classes;
}
declare module "*.css" {
  const content: { [className: string]: string };
  export default content;
}

declare module "*.jpeg" {
  const value: string;
  export default value;
}

declare module "*.jpg" {
  const value: string;
  export default value;
}

declare module "../../data/items" {
  export interface Item {
    src: string;
    alt: string;
    name: string;
    id: string;
    category: string;
  }
}
