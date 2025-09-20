# 51-migrate-login-to-jose.ps1
# Migrate src/app/api/auth/login/route.ts from jsonwebtoken -> jose, rebuild.

$ErrorActionPreference = "Stop"
Set-Location "C:\website"

$loginPath = "C:\website\src\app\api\auth\login\route.ts"

if (!(Test-Path $loginPath)) {
  throw "Missing file: $loginPath"
}

# 1) Backup
$stamp = Get-Date -Format "yyyyMMddHHmmss"
Copy-Item $loginPath "$loginPath.bak.$stamp"

# 2) Ensure jose is present
if (Test-Path "C:\website\package-lock.json") {
  npm i jose
} elseif (Test-Path "C:\website\pnpm-lock.yaml") {
  corepack enable pnpm | Out-Null
  pnpm add jose
} else {
  yarn add jose
}

# 3) Patch the file:
#   - Replace `import jwt from "jsonwebtoken"` with `import { SignJWT } from "jose"`
#   - Replace `jwt.sign(` calls with `await signJwtHS256(` (helper function injected)
#   - Inject helper using jose to mimic jsonwebtoken.sign(payload, secret, { expiresIn })

$content = Get-Content $loginPath -Raw

# Replace import
$content = $content -replace 'import\s+jwt\s+from\s+["'']jsonwebtoken["''];?', 'import { SignJWT } from "jose";'

# Ensure file is TypeScript module with async capability (we'll add helper below)
# Replace jwt.sign( … ) with await signJwtHS256( … )
$content = $content -replace 'jwt\.sign\s*\(', 'await signJwtHS256('

# Inject helper after imports (right below the last import line)
$helper = @"

async function signJwtHS256(payload: any, secretOrOptions?: any, maybeOptions?: any): Promise<string> {
  // Normalize options so existing call sites keep working:
  // jwt.sign(payload, JWT_SECRET, { expiresIn: "7d" })
  const opts = (secretOrOptions && typeof secretOrOptions === "object" && !Array.isArray(secretOrOptions))
    ? secretOrOptions
    : (maybeOptions || {});
  const expiresIn = (opts?.expiresIn || opts?.exp || "7d") as string;

  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error("JWT_SECRET missing");

  const key = new TextEncoder().encode(secret);
  return await new SignJWT(payload)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(expiresIn)
    .sign(key);
}
"@

# Insert helper after the last import statement
if ($content -match '(^import .+$\r?\n)+') {
  $content = $content -replace '((?:^import .+\r?\n)+)', "`$1$helper`n"
} else {
  # No imports found; just prepend helper
  $content = $helper + "`n" + $content
}

Set-Content $loginPath $content -Encoding UTF8
Write-Host "🔧 Migrated jsonwebtoken → jose in $loginPath"

# 4) Rebuild
if (Test-Path "C:\website\pnpm-lock.yaml") {
  corepack enable pnpm | Out-Null
  pnpm install
  pnpm build
} elseif (Test-Path "C:\website\package-lock.json") {
  npm ci
  npm run build
} else {
  yarn install --frozen-lockfile
  yarn build
}

Write-Host "`n✅ Login route migrated and build attempted."

# 5) Deployment instructions (CLI changed: log in & deploy)
Write-Host @"
Next (run manually):

vercel login
vercel link --yes
vercel whoami
vercel deploy --yes
"@
