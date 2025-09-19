import { NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";

export async function GET() {
  const dir = path.join(process.cwd(), "public", "hero");
  try {
    const files = await fs.readdir(dir);
    const urls = files.filter(f => /\.(jpe?g|png|webp|avif)$/i.test(f)).map(f => "/hero/" + f);
    return NextResponse.json({ images: urls });
  } catch {
    return NextResponse.json({ images: [] });
  }
}
