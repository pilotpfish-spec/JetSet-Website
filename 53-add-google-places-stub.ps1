# 53-add-google-places-stub.ps1
# Create a minimal src/components/GooglePlacesInput.tsx (so page.wip builds),
# ensure tsconfig has the "@/*" -> "src/*" alias, then rebuild.

$ErrorActionPreference = "Stop"
Set-Location "C:\website"

# 1) Ensure components dir exists
New-Item -ItemType Directory -Force -Path "C:\website\src\components" | Out-Null

# 2) Write a minimal, drop-in stub for GooglePlacesInput
$compPath = "C:\website\src\components\GooglePlacesInput.tsx"
$stamp = Get-Date -Format "yyyyMMddHHmmss"
if (Test-Path $compPath) { Copy-Item $compPath "$compPath.bak.$stamp" }

$component = @'
import * as React from "react";

type Props = {
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  className?: string;
  id?: string;
  name?: string;
  disabled?: boolean;
};

/**
 * Temporary stub for GooglePlacesInput.
 * - Keeps the same API surface (value/onChange/placeholder/className).
 * - You can swap in real Places Autocomplete later without breaking callers.
 */
export default function GooglePlacesInput({
  value = "",
  onChange,
  placeholder = "Enter an address",
  className = "",
  id,
  name,
  disabled,
}: Props) {
  const [val, setVal] = React.useState(value);

  React.useEffect(() => {
    setVal(value ?? "");
  }, [value]);

  return (
    <input
      id={id}
      name={name}
      className={className || "w-full rounded-xl border px-3 py-2"}
      type="text"
      inputMode="text"
      autoComplete="street-address"
      placeholder={placeholder}
      value={val}
      onChange={(e) => {
        const v = e.currentTarget.value;
        setVal(v);
        onChange?.(v);
      }}
      disabled={disabled}
    />
  );
}
'@
Set-Content -Path $compPath -Value $component -Encoding UTF8
Write-Host "🧩 Wrote stub: src/components/GooglePlacesInput.tsx"

# 3) Ensure tsconfig has @ alias → src
$tsconfigPath = "C:\website\tsconfig.json"
if (Test-Path $tsconfigPath) {
  $json = Get-Content $tsconfigPath -Raw | ConvertFrom-Json
} else {
  $json = [pscustomobject]@{ compilerOptions = [pscustomobject]@{} }
}

if (-not $json.compilerOptions) {
  $json | Add-Member -NotePropertyName compilerOptions -NotePropertyValue ([pscustomobject]@{})
}
if (-not $json.compilerOptions.baseUrl) {
  $json.compilerOptions.baseUrl = "."
}
if (-not $json.compilerOptions.paths) {
  $json.compilerOptions | Add-Member -NotePropertyName paths -NotePropertyValue ([pscustomobject]@{})
}

# Ensure "@/*": ["src/*"]
$paths = $json.compilerOptions.paths
if (-not ($paths.PSObject.Properties.Name -contains "@/*")) {
  $paths | Add-Member -NotePropertyName "@/*" -NotePropertyValue @("src/*")
} else {
  $paths."@/*" = @("src/*")
}

($json | ConvertTo-Json -Depth 100) | Set-Content $tsconfigPath -Encoding UTF8
Write-Host "🔧 Ensured tsconfig alias: '@/*' → 'src/*'"

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

Write-Host "`n✅ Stub added, alias ensured, and build attempted."
