import { NextRequest, NextResponse } from "next/server";
import { calculateFare } from '../../../src/lib/fare';

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

