param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
Set-Location $ProjectRoot

$path = Join-Path $ProjectRoot "src\lib\google.ts"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$code = @'
import { Client, TravelMode } from "@googlemaps/google-maps-services-js";

export type LatLng = { lat: number; lng: number };

export async function routeMetrics(
  origin: string | LatLng,
  destination: string | LatLng,
  apiKey: string
): Promise<{ distanceMeters: number; durationSeconds: number }> {
  const client = new Client({});
  const toText = (p: string | LatLng) => (typeof p === "string" ? p : `${p.lat},${p.lng}`);

  const resp = await client.directions({
    params: {
      origin: toText(origin),
      destination: toText(destination),
      key: apiKey,
      mode: TravelMode.driving,
    },
  });

  const leg = resp.data.routes?.[0]?.legs?.[0];
  if (!leg) throw new Error("No route found");

  return {
    distanceMeters: leg.distance?.value ?? 0,
    durationSeconds: leg.duration?.value ?? 0,
  };
}
'@

[IO.File]::WriteAllText($path, $code, $utf8)
Write-Host "OK: Updated $path"
