import { Client, TravelMode } from "@googlemaps/google-maps-services-js";

export type LatLng = { lat: number; lng: number };

/** Convert meters -> miles (decimal miles). */
export function milesFromMeters(meters: number): number {
  return meters / 1609.344;
}

/** Convert seconds -> minutes (decimal minutes). */
export function minutesFromSeconds(seconds: number): number {
  return seconds / 60;
}

export type RouteMetrics = {
  distanceMeters: number;
  durationSeconds: number;
  startAddress: string;
  endAddress: string;
};

/** Call Google Directions API and return distance/duration + addresses. */
export async function routeMetrics(origin: string | LatLng, destination: string | LatLng, apiKey?: string): Promise<RouteMetrics> {
  const client = new Client({});
  const toText = (p: string | LatLng) => (typeof p === "string" ? p : `${p.lat},${p.lng}`);

  const key = apiKey ?? (process.env.GOOGLE_MAPS_API_KEY ?? '');
  const resp = await client.directions({
    params: {
      origin: toText(origin),
      destination: toText(destination),
      key: key,
      mode: TravelMode.driving,
    },
  });

  const leg = resp.data.routes?.[0]?.legs?.[0];
  if (!leg) throw new Error("No route found");

  return {
    distanceMeters: leg.distance?.value ?? 0,
    durationSeconds: leg.duration?.value ?? 0,
    startAddress: leg.start_address ?? "",
    endAddress: leg.end_address ?? "",
  };
}
