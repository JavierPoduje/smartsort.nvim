import { dd, aa, gg, bb, cc } from "./things.js";

export async function ccc(a: string, b: string): Promise<void> {
  console.log("ccc");
}

// b has a comment
async function bbb(a: string, b: string): Promise<void> {
  console.log("bbb");
}

/**
 * this is a comment too
 */
export function aaa(a: string, b: string) {
  console.log("aaa");
}
