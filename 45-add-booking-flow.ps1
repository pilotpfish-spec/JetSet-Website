Write-Host "🛠 Step 1: Backup schema.prisma..." -ForegroundColor Blue
Copy-Item "prisma\schema.prisma" "prisma\schema.prisma.bak" -Force

Write-Host "📝 Step 2: Append Booking model to schema.prisma..." -ForegroundColor Blue
@'
model Booking {
  id        String   @id @default(cuid())
  userId    String?
  pickup    String
  dropoff   String
  rideType  String   // "to-airport" | "from-airport" | "non-airport"
  fare      Float
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  user User? @relation(fields: [userId], references: [id])
}
'@ | Add-Content "prisma\schema.prisma"

Write-Host "⚡ Step 3: Run Prisma migration..." -ForegroundColor Blue
npx prisma migrate dev --name add-booking --skip-seed

Write-Host "📝 Step 4: Create API route for bookings..." -ForegroundColor Blue
$bookingApiPath = "src\app\api\bookings\route.ts"
New-Item -ItemType Directory -Force -Path (Split-Path $bookingApiPath)

@'
import { NextResponse } from "next/server";
import { PrismaClient } from "@prisma/client";
import mailgun from "mailgun-js";

const prisma = new PrismaClient();

export async function POST(req: Request) {
  try {
    const { pickup, dropoff, rideType } = await req.json();

    if (!pickup || !dropoff || !rideType) {
      return NextResponse.json({ error: "Missing required fields" }, { status: 400 });
    }

    // Fare logic
    let fare = 0;
    if (rideType === "to-airport") {
      fare = 45;
    } else if (rideType === "from-airport") {
      fare = 55;
    } else {
      fare = 35;
    }

    const booking = await prisma.booking.create({
      data: { pickup, dropoff, rideType, fare },
    });

    // Mailgun
    const mg = mailgun({
      apiKey: process.env.MAILGUN_API_KEY!,
      domain: process.env.MAILGUN_DOMAIN!,
    });

    await mg.messages().send({
      from: "JetSet Direct <no-reply@jetsetdirect.com>",
      to: "pilotpfish@gmail.com",
      subject: "🚖 New Booking",
      text: `Booking ID: ${booking.id}
Pickup: ${pickup}
Dropoff: ${dropoff}
Type: ${rideType}
Fare: $${fare}`,
    });

    return NextResponse.json({ success: true, booking });
  } catch (error) {
    console.error("Booking error:", error);
    return NextResponse.json({ error: "Server error" }, { status: 500 });
  }
}
'@ | Out-File -Encoding UTF8 $bookingApiPath

Write-Host "✅ Booking model + API route added!" -ForegroundColor Green
