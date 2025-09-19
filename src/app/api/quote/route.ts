import { NextResponse } from "next/server";
import { z } from "zod";
import { routeMetrics } from "@/lib/google";
import { DEFAULT_CONFIG, computeFare } from "@/lib/pricing";
import { airportFullName } from "@/lib/airports";

const schema = z.object({
  mode: z.enum(["TO_AIRPORT","FROM_AIRPORT","POINT_TO_POINT"]),
  airportCode: z.string().optional(),
  origin: z.string(),
  dest: z.string(),
  p2pWaitMinutes: z.number().int().nonnegative().optional()
});

export async function POST(req: Request) {
  const body = await req.json();
  const { mode, airportCode, origin, dest, p2pWaitMinutes } = schema.parse(body);

  let originAddr = origin, destAddr = dest, airportName = "";
  if (mode !== "POINT_TO_POINT") {
    if (!airportCode) return NextResponse.json({ error: "airportCode required" }, { status: 400 });
    airportName = airportFullName(airportCode);
    if (mode === "TO_AIRPORT") destAddr = airportName;
    if (mode === "FROM_AIRPORT") originAddr = airportName;
  }

  const { distanceMeters, durationSeconds, startAddress, endAddress } = await routeMetrics(originAddr, destAddr);

  const fare = computeFare(DEFAULT_CONFIG, {
    mode,
    airportCode: mode === "POINT_TO_POINT" ? undefined : airportCode,
    distanceMeters,
    durationSeconds,
    p2pWaitMinutes: mode === "POINT_TO_POINT" ? (p2pWaitMinutes ?? 0) : 0
  });

  return NextResponse.json({
    distanceMeters,
    durationSeconds,
    distanceMiles: distanceMeters / 1609.344,
    durationMinutes: durationSeconds / 60,
    originAddress: startAddress,
    destAddress: endAddress,
    breakdown: fare,
    totalCents: fare.totalCents,
    expiresAt: new Date(Date.now() + 15*60*1000).toISOString()
  });
}
