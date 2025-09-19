import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { hashPassword } from "@/lib/password";

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const email = (body.email || "").toString().trim().toLowerCase();
    const password = (body.password || "").toString();
    const name = body.name ? String(body.name) : null;
    const phone = body.phone ? String(body.phone) : null;

    if (!email || !password) {
      return NextResponse.json({ error: "Email and password required" }, { status: 400 });
    }

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return NextResponse.json({ error: "Email already in use" }, { status: 400 });
    }

    const hashedPassword = await hashPassword(password);

    const user = await prisma.user.create({
      data: {
        email,
        hashedPassword,
        name,
        phone
      },
      select: { id: true, email: true, name: true }
    });

    return NextResponse.json({ ok: true, user }, { status: 201 });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ error: "Server error" }, { status: 500 });
  }
}
