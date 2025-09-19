# 30-setup-auth-and-models.ps1
# Sets up NextAuth (Credentials), Prisma models (User/Account/Session/VerificationToken/SavedAddress/Booking),
# API routes (register/auth/addresses/bookings), and local NEXTAUTH env vars.

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Resolve repo root even if script is called from elsewhere
$root = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
Set-Location $root

Write-Host "==> Setting up Auth, Saved Addresses, and Booking scaffolding..."

# --- Sanity checks ---
if (-not (Test-Path (Join-Path $root "package.json"))) {
  throw "package.json not found. Run this from the project root (C:\website)."
}
if (-not (Test-Path (Join-Path $root "prisma\schema.prisma"))) {
  throw "prisma\schema.prisma not found."
}

# --- Ensure .env.local and auth env keys present (local only) ---
$envFile = Join-Path $root ".env.local"
if (-not (Test-Path $envFile)) {
  Write-Host "Creating .env.local ..."
  New-Item -ItemType File -Path $envFile | Out-Null
}
$envText = Get-Content $envFile -Raw

function Add-Or-Update-Env {
  param([string]$Key,[string]$Value)
  if ($envText -match "^\s*$([regex]::Escape($Key))=") {
    # Already there; leave as-is
    return
  } else {
    Add-Content -Path $envFile -Value "$Key=$Value"
  }
}

# Generate a random NEXTAUTH_SECRET if missing (local dev)
if ($envText -notmatch '^NEXTAUTH_SECRET=') {
  try {
    $secret = node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
  } catch {
    # Fallback if node call fails
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[] 32
    $rng.GetBytes($bytes)
    $secret = [BitConverter]::ToString($bytes).Replace('-', '').ToLower()
  }
  Add-Or-Update-Env -Key "NEXTAUTH_SECRET" -Value $secret
  Write-Host "Wrote NEXTAUTH_SECRET to .env.local"
}

if ($envText -notmatch '^NEXTAUTH_URL=') {
  Add-Or-Update-Env -Key "NEXTAUTH_URL" -Value "http://localhost:3000"
  Write-Host "Wrote NEXTAUTH_URL=http://localhost:3000 to .env.local"
}

# --- Install deps ---
Write-Host "Installing NextAuth, Prisma adapter, and bcrypt..."
& "$env:ProgramFiles\nodejs\npm.cmd" i next-auth @auth/prisma-adapter bcryptjs @types/bcryptjs --save | Out-Null

# --- Patch prisma schema ---
$schemaPath = Join-Path $root "prisma\schema.prisma"
$schema = Get-Content $schemaPath -Raw

# Backup once
$bak = Join-Path $root "prisma\schema.prisma.bak_$(Get-Date -Format yyyyMMdd_HHmmss)"
$schema | Set-Content -Encoding UTF8 $bak
Write-Host "Backup saved: $bak"

function Append-If-Missing {
  param([string]$Needle,[string]$Block)
  if ($schema -notmatch $Needle) {
    $global:schema += "`r`n`r`n$Block`r`n"
  }
}

# NextAuth models (based on official Prisma schema)
$blockUser = @'
model User {
  id               String   @id @default(cuid())
  name             String?
  email            String?  @unique
  emailVerified    DateTime?
  image            String?
  hashedPassword   String?
  phone            String?
  stripeCustomerId String?

  addresses SavedAddress[]
  bookings  Booking[]
  accounts  Account[]
  sessions  Session[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
'@

$blockAccount = @'
model Account {
  id                 String  @id @default(cuid())
  userId             String
  type               String
  provider           String
  providerAccountId  String
  refresh_token      String? @db.Text
  access_token       String? @db.Text
  expires_at         Int?
  token_type         String?
  scope              String?
  id_token           String? @db.Text
  session_state      String?

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerAccountId])
}
'@

$blockSession = @'
model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}
'@

$blockVerificationToken = @'
model VerificationToken {
  identifier String
  token      String   @unique
  expires    DateTime

  @@unique([identifier, token])
}
'@

$blockSavedAddress = @'
model SavedAddress {
  id        String   @id @default(cuid())
  userId    String
  label     String
  address   String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}
'@

# Reuse existing enum BookingStatus if present; otherwise define it
$blockBookingStatus = @'
enum BookingStatus {
  PENDING
  CONFIRMED
  CANCELLED
  REFUNDED
}
'@

$blockBooking = @'
model Booking {
  id              String         @id @default(cuid())
  userId          String
  mode            String         // "TO_AIRPORT" | "FROM_AIRPORT" | "POINT_TO_POINT"
  airportCode     String?
  originAddress   String
  destAddress     String?
  scheduledAt     DateTime
  distanceMeters  Int
  durationSeconds Int
  totalCents      Int
  breakdownJson   String         @db.Text
  status          BookingStatus  @default(PENDING)
  createdAt       DateTime       @default(now())
  updatedAt       DateTime       @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}
'@

Append-If-Missing -Needle '\bmodel\s+User\b' -Block $blockUser
Append-If-Missing -Needle '\bmodel\s+Account\b' -Block $blockAccount
Append-If-Missing -Needle '\bmodel\s+Session\b' -Block $blockSession
Append-If-Missing -Needle '\bmodel\s+VerificationToken\b' -Block $blockVerificationToken
Append-If-Missing -Needle '\bmodel\s+SavedAddress\b' -Block $blockSavedAddress
if ($schema -notmatch '\benum\s+BookingStatus\b') {
  Append-If-Missing -Needle 'THIS_WILL_NEVER_MATCH' -Block $blockBookingStatus
}
Append-If-Missing -Needle '\bmodel\s+Booking\b' -Block $blockBooking

# Write schema back
$schema | Set-Content -Encoding UTF8 $schemaPath
Write-Host "Updated prisma\schema.prisma"

# --- Write TS helpers and routes ---
function Write-File {
  param([string]$RelPath,[string]$Content)
  $path = Join-Path $root $RelPath
  $dir = Split-Path $path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $Content | Set-Content -Encoding UTF8 $path
  Write-Host "Wrote $RelPath"
}

$prismaTs = @'
import { PrismaClient } from "@prisma/client";

const globalForPrisma = global as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
'@
Write-File -RelPath "src\lib\prisma.ts" -Content $prismaTs

$passwordTs = @'
import bcrypt from "bcryptjs";

export async function hashPassword(password: string): Promise<string> {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(password, salt);
}

export function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
'@
Write-File -RelPath "src\lib\password.ts" -Content $passwordTs

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
        if (!user || !user.hashedPassword) return null;
        const ok = await verifyPassword(credentials.password, user.hashedPassword);
        if (!ok) return null;
        return { id: user.id, email: user.email, name: user.name ?? undefined };
      },
    }),
  ],
  pages: {
    signIn: "/admin/login",
  },
  callbacks: {
    async session({ session, token }) {
      if (session.user && token.sub) {
        (session.user as any).id = token.sub;
      }
      return session;
    },
  },
};
'@
Write-File -RelPath "src\lib\auth.ts" -Content $authTs

$authRoute = @'
import NextAuth from "next-auth";
import { authOptions } from "@/lib/auth";

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
'@
Write-File -RelPath "src\app\api\auth\[...nextauth]\route.ts" -Content $authRoute

$registerRoute = @'
import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { hashPassword } from "@/lib/password";

export async function POST(req: Request) {
  try {
    const { email, password, name, phone } = await req.json();
    if (!email || !password) return NextResponse.json({ error: "Missing email or password" }, { status: 400 });

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) return NextResponse.json({ error: "Email already in use" }, { status: 409 });

    const hashedPassword = await hashPassword(password);
    const user = await prisma.user.create({ data: { email, hashedPassword, name, phone } });
    return NextResponse.json({ ok: true, id: user.id });
  } catch (e) {
    return NextResponse.json({ error: "Bad Request" }, { status: 400 });
  }
}
'@
Write-File -RelPath "src\app\api\auth\register\route.ts" -Content $registerRoute

$addressesRoute = @'
import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";

export async function GET() {
  const session = await getServerSession(authOptions);
  const uid = (session?.user as any)?.id as string | undefined;
  if (!uid) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const items = await prisma.savedAddress.findMany({
    where: { userId: uid },
    orderBy: { createdAt: "desc" },
  });
  return NextResponse.json({ items });
}

export async function POST(req: Request) {
  const session = await getServerSession(authOptions);
  const uid = (session?.user as any)?.id as string | undefined;
  if (!uid) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { label, address } = await req.json();
  if (!label || !address) return NextResponse.json({ error: "Missing label or address" }, { status: 400 });

  const row = await prisma.savedAddress.create({ data: { userId: uid, label, address } });
  return NextResponse.json({ id: row.id });
}
'@
Write-File -RelPath "src\app\api\addresses\route.ts" -Content $addressesRoute

$bookingsRoute = @'
import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { routeMetrics } from "@/lib/google";
import { computeFare, DEFAULT_CONFIG } from "@/lib/pricing";

export async function POST(req: Request) {
  const session = await getServerSession(authOptions);
  const uid = (session?.user as any)?.id as string | undefined;
  if (!uid) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const { mode, airportCode, origin, dest, p2pWaitMinutes = 0, scheduledAt } = body || {};
  if (!mode || !origin || (!dest && mode === "POINT_TO_POINT") || !scheduledAt) {
    return NextResponse.json({ error: "Missing required fields" }, { status: 400 });
  }

  const metrics = await routeMetrics(origin, dest ?? (airportCode || ""));
  const { distanceMeters, durationSeconds, startAddress, endAddress } = metrics;

  const fare = computeFare(DEFAULT_CONFIG, {
    mode,
    airportCode,
    distanceMeters,
    durationSeconds,
    p2pWaitMinutes: mode === "POINT_TO_POINT" ? Number(p2pWaitMinutes || 0) : 0,
  });

  const booking = await prisma.booking.create({
    data: {
      userId: uid,
      mode,
      airportCode,
      originAddress: startAddress,
      destAddress: endAddress ?? null,
      scheduledAt: new Date(scheduledAt),
      distanceMeters,
      durationSeconds,
      totalCents: fare.totalCents,
      breakdownJson: JSON.stringify(fare.breakdown),
      status: "PENDING",
    },
  });

  return NextResponse.json({ id: booking.id, totalCents: fare.totalCents });
}
'@
Write-File -RelPath "src\app\api\bookings\route.ts" -Content $bookingsRoute

# Type augmentation so session.user.id is typed
$nextAuthTypes = @'
import "next-auth";

declare module "next-auth" {
  interface Session {
    user: {
      id: string;
      name?: string | null;
      email?: string | null;
      image?: string | null;
    };
  }
}
'@
Write-File -RelPath "src\types\next-auth.d.ts" -Content $nextAuthTypes

# Optional: update admin login page to use NextAuth sign-in/sign-up if file exists
$loginPage = Join-Path $root "src\app\admin\login\page.tsx"
if (Test-Path $loginPage) {
  $loginTsx = @'
"use client";
import { useState } from "react";
import { signIn } from "next-auth/react";

export default function LoginPage() {
  const [mode, setMode] = useState<"signin"|"signup">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string|null>(null);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      if (mode === "signup") {
        const r = await fetch("/api/auth/register", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email, password, name, phone }),
        });
        const j = await r.json();
        if (!r.ok) throw new Error(j.error || "Sign up failed");
      }
      const res = await signIn("credentials", { email, password, redirect: true, callbackUrl: "/" });
      // signIn will redirect on success; if it returns, handle potential error
      if ((res as any)?.error) setError("Sign in failed");
    } catch (err:any) {
      setError(err.message || "Something went wrong");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="max-w-md mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">{mode === "signin" ? "Sign in" : "Create account"}</h1>
      <div className="mb-4 flex gap-2">
        <button className={`px-3 py-1 border rounded ${mode==="signin"?"bg-gray-100":""}`} onClick={()=>setMode("signin")}>Sign in</button>
        <button className={`px-3 py-1 border rounded ${mode==="signup"?"bg-gray-100":""}`} onClick={()=>setMode("signup")}>Sign up</button>
      </div>
      <form onSubmit={submit} className="space-y-3">
        {mode==="signup" && (
          <>
            <input className="border rounded p-2 w-full" placeholder="Full name" value={name} onChange={e=>setName(e.target.value)} />
            <input className="border rounded p-2 w-full" placeholder="Phone" value={phone} onChange={e=>setPhone(e.target.value)} />
          </>
        )}
        <input className="border rounded p-2 w-full" type="email" placeholder="Email" value={email} onChange={e=>setEmail(e.target.value)} required />
        <input className="border rounded p-2 w-full" type="password" placeholder="Password" value={password} onChange={e=>setPassword(e.target.value)} required />
        {error && <div className="text-red-600 text-sm">{error}</div>}
        <button className="px-4 py-2 rounded bg-[#FBC02D] text-[#0F1F39]" disabled={loading}>
          {loading ? "Working..." : (mode==="signin" ? "Sign in" : "Create account")}
        </button>
      </form>
    </main>
  );
}
'@
  $loginTsx | Set-Content -Encoding UTF8 $loginPage
  Write-Host "Updated src\app\admin\login\page.tsx"
}

# --- Prisma format/generate/push ---
Write-Host "Formatting Prisma schema..."
& "$env:ProgramFiles\nodejs\npx.cmd" prisma format | Out-Null
Write-Host "Generating Prisma client..."
& "$env:ProgramFiles\nodejs\npx.cmd" prisma generate | Out-Null
Write-Host "Pushing schema to DB..."
& "$env:ProgramFiles\nodejs\npx.cmd" prisma db push | Out-Null

Write-Host "`nOK: Auth + models + API scaffolding installed."
Write-Host "Next:"
Write-Host " 1) npm run build"
Write-Host " 2) Start locally: PowerShell -ExecutionPolicy Bypass -File .\19-start-local.ps1"
Write-Host " 3) Push NEXTAUTH_* to Vercel (see instructions below)."
