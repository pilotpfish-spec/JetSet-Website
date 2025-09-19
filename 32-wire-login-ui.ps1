# 32-wire-login-ui.ps1
$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
  param([string]$Path, [string]$Content)
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Backup-IfExists([string]$Path) {
  if (Test-Path $Path) {
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item $Path "$Path.bak_$ts" -Force
  }
}

Write-Host "==> Patching admin login to use NextAuth and adding Create Account link..."

# New admin login page (client)
$loginClient = @'
"use client";
import { useState } from "react";
import { signIn } from "next-auth/react";
import Link from "next/link";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const res = await signIn("credentials", {
        email: email.trim().toLowerCase(),
        password,
        redirect: false,
      });

      if (res?.error) {
        setError("Invalid email or password.");
        setLoading(false);
        return;
      }

      // success -> go to booking
      window.location.href = "/booking";
    } catch {
      setError("Unexpected error. Please try again.");
      setLoading(false);
    }
  };

  return (
    <div className="max-w-md mx-auto p-6 bg-white rounded-xl shadow mt-10">
      <div className="flex justify-center mb-4">
        <img src="/logo.png" alt="JetSet Direct" className="h-8" />
      </div>
      <h1 className="text-2xl font-semibold mb-4 text-[#0F1F39]">Log In</h1>

      <form onSubmit={onSubmit} className="space-y-3">
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
          <label className="block text-sm mb-1">Password</label>
          <input
            className="w-full border rounded p-2"
            type="password"
            value={password}
            onChange={e=>setPassword(e.target.value)}
            placeholder="Your password"
            autoComplete="current-password"
            required
          />
        </div>

        {error ? <div className="text-red-600 text-sm">{error}</div> : null}

        <button
          className="w-full px-4 py-2 rounded font-semibold text-[#0F1F39]"
          style={{ background: "#FBC02D" }}
          disabled={loading}
        >
          {loading ? "Signing in..." : "Sign In"}
        </button>
      </form>

      <div className="text-sm text-gray-600 mt-4 flex items-center justify-between">
        <span>
          Don&apos;t have an account?{" "}
          <Link className="underline" href="/signup">Create one</Link>
        </span>
        <span className="text-gray-400">|</span>
        <Link className="underline text-gray-600" href="/contact">Need help?</Link>
      </div>
    </div>
  );
}
'@

# /login alias that redirects to /admin/login (server component)
$loginAlias = @'
import { redirect } from "next/navigation";

export default function Page() {
  redirect("/admin/login");
}
'@

$adminLoginPath = Join-Path $PSScriptRoot "src\app\admin\login\page.tsx"
$loginAliasPath = Join-Path $PSScriptRoot "src\app\login\page.tsx"

Backup-IfExists $adminLoginPath
Write-Utf8NoBom -Path $adminLoginPath -Content $loginClient

Backup-IfExists $loginAliasPath
Write-Utf8NoBom -Path $loginAliasPath -Content $loginAlias

Write-Host "Files written:"
Write-Host " - $adminLoginPath"
Write-Host " - $loginAliasPath"

# Build to validate
if (Test-Path "$env:ProgramFiles\nodejs\npm.cmd") {
  Write-Host "==> Building project…"
  & "$env:ProgramFiles\nodejs\npm.cmd" run build
  if ($LASTEXITCODE -ne 0) { throw "Build failed (code $LASTEXITCODE)" }
}

Write-Host "OK: Login wired to NextAuth. Users can go to /admin/login (or /login) and click 'Create one' to reach /signup."
