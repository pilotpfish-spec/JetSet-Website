# 42-fix-auth.ps1
# Replaces src\lib\auth.ts with corrected code using `hashedPassword`

$root = "C:\website"
Set-Location $root
$path = Join-Path $root "src\lib\auth.ts"

$new = @"
import { type NextAuthOptions } from "next-auth";
import Credentials from "next-auth/providers/credentials";
import { prisma } from "@/lib/prisma";
import { verifyPassword } from "@/lib/password";

export const authOptions: NextAuthOptions = {
  session: { strategy: "jwt" },
  providers: [
    Credentials({
      name: "Email & Password",
      credentials: {
        email: { label: "Email", type: "text" },
        password: { label: "Password", type: "password" }
      },
      async authorize(credentials) {
        const email = (credentials?.email ?? "").toString().trim().toLowerCase();
        const password = (credentials?.password ?? "").toString();

        if (!email || !password) return null;

        const user = await prisma.user.findUnique({ where: { email } });
        // Prisma model uses `hashedPassword` (not passwordHash)
        if (!user || !user.hashedPassword) return null;

        const ok = await verifyPassword(password, user.hashedPassword);
        if (!ok) return null;

        return { id: user.id, email: user.email!, name: user.name ?? undefined };
      }
    })
  ],
  pages: { signIn: "/admin/login" }
};
export default authOptions;
"@

$new | Set-Content $path -Encoding UTF8

# Build + deploy
npm run build
if ($LASTEXITCODE -ne 0) { throw "Build failed" }
vercel --prod --yes
