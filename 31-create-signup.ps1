# 31-create-signup.ps1
# Scaffolds Signup page + Register API and builds.
$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$Content
  )
  $dir = Split-Path -Path $Path -Parent
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Backup-IfExists {
  param([string]$Path)
  if (Test-Path $Path) {
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item $Path "$Path.bak_$ts" -Force
  }
}

Write-Host "==> Creating Signup page and Register API..."

# -------------------------
# signup page (client)
# -------------------------
$signupPage = @'
"use client";
import { useState } from "react";
import { signIn } from "next-auth/react";
import Link from "next/link";

export default function SignupPage() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    const trimmedEmail = email.trim().toLowerCase();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmedEmail)) {
      setError("Please enter a valid email.");
      return;
    }
    if (password.length < 8) {
      setError("Password must be at least 8 characters.");
      return;
    }
    if (password !== confirm) {
      setError("Passwords do not match.");
      return;
    }

    setSubmitting(true);
    try {
      const resp = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, email: trimmedEmail, phone, password })
      });

      const data = await resp.json();
      if (!resp.ok) {
        setError(data?.error ?? "Registration failed.");
        setSubmitting(false);
        return;
      }

      // Auto sign-in, then send to booking
      await signIn("credentials", {
        email: trimmedEmail,
        password,
        redirect: true,
        callbackUrl: "/booking"
      });
    } catch (err) {
      setError("Unexpected error. Please try again.");
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-md mx-auto p-6 bg-white rounded-xl shadow mt-10">
      <h1 className="text-2xl font-semibold mb-4 text-[#0F1F39]">Create your account</h1>

      <form onSubmit={onSubmit} className="space-y-3">
        <div>
          <label className="block text-sm mb-1">Name</label>
          <input
            className="w-full border rounded p-2"
            value={name}
            onChange={e=>setName(e.target.value)}
            placeholder="Jane Doe"
            autoComplete="name"
          />
        </div>

        <div>
          <label className="block text-sm mb-1">Email</label>
          <input
            className="w-full border rounded p-2"
            type="email"
            value={email}
            onChange={e=>setEmail(e.target.value)}
            placeholder="you@example.com"
            autoComplete="email"
            required
          />
        </div>

        <div>
          <label className="block text-sm mb-1">Phone</label>
          <input
            className="w-full border rounded p-2"
            type="tel"
            value={phone}
            onChange={e=>setPhone(e.target.value)}
            placeholder="(555) 555-5555"
            autoComplete="tel"
          />
        </div>

        <div>
          <label className="block text-sm mb-1">Password</label>
          <input
            className="w-full border rounded p-2"
            type="password"
            value={password}
            onChange={e=>setPassword(e.target.value)}
            placeholder="At least 8 characters"
            autoComplete="new-password"
            required
          />
        </div>

        <div>
          <label className="block text-sm mb-1">Confirm Password</label>
          <input
            className="w-full border rounded p-2"
            type="password"
            value={confirm}
            onChange={e=>setConfirm(e.target.value)}
            placeholder="Re-type password"
            autoComplete="new-password"
            required
          />
        </div>

        {error ? <div className="text-red-600 text-sm">{error}</div> : null}

        <button
          className="w-full px-4 py-2 rounded font-semibold text-[#0F1F39]"
          style={{ background: "#FBC02D" }}
          disabled={submitting}
        >
          {submitting ? "Creating account..." : "Create account"}
        </button>
      </form>

      <div className="text-sm text-gray-600 mt-4">
        Already have an account?{" "}
        <Link href="/admin/login" className="underline">Log in</Link>
      </div>
    </div>
  );
}
'@

# -------------------------
# register API route (server)
# -------------------------
$registerRoute = @'
import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { hashPassword } from "@/lib/password";

function isEmail(v: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const name: string = (body?.name ?? "").toString().trim();
    const emailRaw: string = (body?.email ?? "").toString().trim().toLowerCase();
    const phoneRaw: string = (body?.phone ?? "").toString().trim();
    const password: string = (body?.password ?? "").toString();

    if (!isEmail(emailRaw)) {
      return NextResponse.json({ error: "Invalid email." }, { status: 400 });
    }
    if (password.length < 8) {
      return NextResponse.json({ error: "Password must be at least 8 characters." }, { status: 400 });
    }

    const existing = await prisma.user.findUnique({ where: { email: emailRaw } });
    if (existing) {
      return NextResponse.json({ error: "Email already registered." }, { status: 409 });
    }

    const passwordHash = await hashPassword(password);
    await prisma.user.create({
      data: {
        email: emailRaw,
        name: name || null,
        phone: phoneRaw ? phoneRaw : null,
        passwordHash
      }
    });

    return NextResponse.json({ ok: true });
  } catch (err) {
    console.error("register error:", err);
    return NextResponse.json({ error: "Server error." }, { status: 500 });
  }
}
'@

# Write files (with backup if they already exist)
$signupPath = Join-Path $PSScriptRoot "src\app\signup\page.tsx"
$registerPath = Join-Path $PSScriptRoot "src\app\api\auth\register\route.ts"

Backup-IfExists $signupPath
Backup-IfExists $registerPath

Write-Utf8NoBom -Path $signupPath -Content $signupPage
Write-Utf8NoBom -Path $registerPath -Content $registerRoute

Write-Host "Files written:"
Write-Host " - $signupPath"
Write-Host " - $registerPath"

# Optional build to validate
if (Test-Path "$env:ProgramFiles\nodejs\npm.cmd") {
  Write-Host "==> Building project…"
  & "$env:ProgramFiles\nodejs\npm.cmd" run build
  if ($LASTEXITCODE -ne 0) { throw "Build failed (code $LASTEXITCODE)" }
}

Write-Host "OK: Signup scaffolding created. Visit /signup to register, then you'll be auto-logged in and sent to /booking."
