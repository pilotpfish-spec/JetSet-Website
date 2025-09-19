import fs from "fs";
import path from "path";
import { NextResponse } from "next/server";

export async function GET() {
  const heroDir = path.join(process.cwd(), "public", "hero");
  const files = fs.readdirSync(heroDir);
  const images = files
    .filter((f) => /\.(png|jpg|jpeg|webp)$/i.test(f))
    .map((f) => `/hero/${f}`);
  return NextResponse.json(images);
}
