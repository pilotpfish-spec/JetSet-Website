# 30b-fix-auth-field.ps1
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$root = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
Set-Location $root

function Write-Text($path, $content) {
  $dir = Split-Path -Parent $path
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  Set-Content -Path $path -Value $content -Encoding UTF8
  Write-Host "Wrote $path"
}

# --- Fix src/lib/auth.ts to use passwordHash ---
$authTs = @'
import type { NextAuthOptions } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import { PrismaAdapter } from "@auth/prisma-adapter";
import { prisma } from "./prisma";
import { verifyPassword } from "./password";

export const authOptions: NextAuthOptions = {
  adapter: PrismaAdapter(prisma) as any,
  session: { strategy: "jwt" },
  secret: process.env.NEXTAUTH_SECRET,
  providers: [
    CredentialsProvider({
      name: "Email & Password",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) return null;
        const user = await prisma.user.findUnique({ where: { email: credentials.email } });
        if (!user || !('passwordHash' in user) || !user.passwordHash) return null;
        const ok = await verifyPassword(credentials.password, user.passwordHash);
        if (!ok) return null;
        return { id: user.id, email: user.email!, name: user.name ?? undefined };
      },
    }),
  ],
  pages: { signIn: "/admin/login" },
  callbacks: {
    async session({ session, token }) {
      if (session.user && token?.sub) (session.user as any).id = token.sub;
      return session;
    },
  },
};
'@
Write-Text "$root\src\lib\auth.ts" $authTs

# --- Ensure the NextAuth route exists ---
$authRoute = @'
import NextAuth from "next-auth";
import { authOptions } from "@/lib/auth";
const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
'@
Write-Text "$root\src\app\api\auth\[...nextauth]\route.ts" $authRoute

# --- Fix the registration route to write passwordHash ---
$registerRoute = @'
import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { hashPassword } from "@/lib/password";

export async function POST(req: Request) {
  try {
    const { email, password, name, phone } = await req.json();
    if (!email || !password) {
      return NextResponse.json({ error: "Missing email or password" }, { status: 400 });
    }
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) return NextResponse.json({ error: "Email already in use" }, { status: 409 });

    const passwordHash = await hashPassword(password);
    const user = await prisma.user.create({ data: { email, passwordHash, name, phone } });
    return NextResponse.json({ ok: true, id: user.id });
  } catch {
    return NextResponse.json({ error: "Bad Request" }, { status: 400 });
  }
}
'@
Write-Text "$root\src\app\api\auth\register\route.ts" $registerRoute

Write-Host "`nOK: Auth files patched to use passwordHash."
