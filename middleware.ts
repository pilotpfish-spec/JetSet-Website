import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { jwtVerify } from "jose";

export async function middleware(req: NextRequest) {
  const token = req.cookies.get("token")?.value;
  const secret = process.env.JWT_SECRET;

  if (!token || !secret) return NextResponse.next();

  try {
    const key = new TextEncoder().encode(secret);
    await jwtVerify(token, key);
    return NextResponse.next();
  } catch {
    const res = NextResponse.redirect(new URL("/login", req.url));
    res.cookies.delete("token");
    return res;
  }
}
// export const config = { matcher: ["/admin/:path*", "/api/private/:path*"] };
