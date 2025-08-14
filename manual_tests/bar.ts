import { bb, dd, aa, cc, hola } from "somewhere.js";

type greetings = "hi |" | "bye" | "| goodbye";

class Point {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }

      scale(n: number): void {
    this.x *= n;
    this.y *= n;
  }

  asString(): string {
    return `(${this.x}, ${this.y})`;
  }
}
