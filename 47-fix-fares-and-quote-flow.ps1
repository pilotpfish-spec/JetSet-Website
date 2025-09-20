# 47-fix-fares-and-quote-flow.ps1
# Purpose: Fix fare calc bug, update quote API, clean up helper text, build & deploy.

$ErrorActionPreference = "Stop"

# 1) Go to repo root
Set-Location "C:\website"
Write-Host "📁 Using repo at C:\website"

# 2) Ensure dirs exist
$fareDir = "C:\website\src\lib"
$apiQuoteDir = "C:\website\app\api\quote"
$componentsDir = "C:\website\src\components"

New-Item -ItemType Directory -Force -Path $fareDir | Out-Null
New-Item -ItemType Directory -Force -Path $apiQuoteDir | Out-Null
New-Item -ItemType Directory -Force -Path $componentsDir | Out-Null

# 3) Backup targeted files if they exist
$targets = @(
  "src\lib\fare.ts",
  "app\api\quote\route.ts",
  "src\components\AddressField.tsx",
  "src\components\QuoteForm.tsx"
)
$stamp = Get-Date -Format "yyyyMMddHHmmss"
foreach ($t in $targets) {
  $p = "C:\website\$t"
  if (Test-Path $p) {
    Copy-Item $p "$p.bak.$stamp"
  }
}

# 4) Correct fare engine
$fareTs = @'
export type RideMode = "toAirport" | "fromAirport" | "nonAirport";

export interface FareInput {
  mode: RideMode;
  distanceMiles: number;
  durationMinutes: number;
  pickupAt?: string;
}

const BASE_FLAG = 7.5;
const PER_MILE = 2.85;
const PER_MIN = 0.45;
const AIRPORT_SURCHARGE = 8.0;
const MIN_FARE = 35;

export function calculateFare(input: FareInput): number {
  const miles = Math.max(0, input.distanceMiles || 0);
  const mins  = Math.max(0, input.durationMinutes || 0);

  let fare = BASE_FLAG + (miles * PER_MILE) + (mins * PER_MIN);

  if (input.mode === "toAirport" || input.mode === "fromAirport") {
    fare += AIRPORT_SURCHARGE;
  }

  if (fare < MIN_FARE) fare = MIN_FARE;
  return Math.round(fare * 100) / 100;
}
'@
Set-Content -Path "C:\website\src\lib\fare.ts" -Value $fareTs -Encoding UTF8

# 5) Quote API
$quoteRoute = @'
import { NextRequest, NextResponse } from "next/server";
import { calculateFare } from "@/src/lib/fare";

type Body = {
  mode: "toAirport" | "fromAirport" | "nonAirport";
  distanceMiles: number;
  durationMinutes: number;
};

export async function POST(req: NextRequest) {
  try {
    const body = (await req.json()) as Body;

    if (!body?.mode || body.distanceMiles == null || body.durationMinutes == null) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    const total = calculateFare({
      mode: body.mode,
      distanceMiles: Number(body.distanceMiles),
      durationMinutes: Number(body.durationMinutes),
    });

    return NextResponse.json({ total });
  } catch (err) {
    console.error("Quote error:", err);
    return NextResponse.json({ error: "Quote failed" }, { status: 500 });
  }
}
'@
Set-Content -Path "C:\website\app\api\quote\route.ts" -Value $quoteRoute -Encoding UTF8

# 6) Remove helper text
$addrFile = "C:\website\src\components\AddressField.tsx"
if (Test-Path $addrFile) {
  $addrContent = Get-Content $addrFile -Raw
  $addrContent = $addrContent -replace "(?s)<p className=""text-xs text-muted-foreground"">.*?</p>", ""
  Set-Content $addrFile $addrContent -Encoding UTF8
}

# 7) QuoteForm toggle
$quoteForm = "C:\website\src\components\QuoteForm.tsx"
if (Test-Path $quoteForm) {
  $q = Get-Content $quoteForm -Raw
  if ($q -notmatch "setQuoted") {
    $q = $q -replace "const \[total, setTotal\][^\n]*\n", "const [total, setTotal] = React.useState<number | null>(null);\nconst [quoted, setQuoted] = React.useState(false);\n"
    $q = $q -replace "(setTotal\(.+?\);\s*)", "$1setQuoted(true);\n"
  }
  if ($q -match "Get Quote" -and $q -notmatch "quoted") {
    $q += @'

{/* Toggle Get Quote → Book Now */}
{quoted ? (
  <button className="btn btn-primary w-full" type="button">Book Now</button>
) : (
  <button className="btn btn-secondary w-full" type="submit">Get Quote</button>
)}
'@
  }
  Set-Content $quoteForm $q -Encoding UTF8
}

# 8) Build
if (Test-Path "C:\website\pnpm-lock.yaml") {
  corepack enable pnpm | Out-Null
  pnpm install
  pnpm prisma generate
  pnpm lint --fix
  pnpm build
} elseif (Test-Path "C:\website\package-lock.json") {
  npm ci
  npx prisma generate
  npm run lint --if-present
  npm run build
} else {
  yarn install --frozen-lockfile
  yarn prisma generate
  yarn build
}

# 9) Deploy
vercel deploy --prod --confirm

Write-Host "`n✅ Fare engine fixed, quote API updated, helper text removed, build & deploy completed."
