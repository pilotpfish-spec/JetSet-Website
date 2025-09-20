Write-Host "🛠 Step 1: Backup schema.prisma..."
Copy-Item "prisma\schema.prisma" "prisma\schema.booking.bak" -Force

Write-Host "📝 Step 2: Overwrite schema.prisma with corrected Booking + User relation..."
@'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id             String    @id @default(cuid())
  name           String?
  email          String?   @unique
  phone          String?
  hashedPassword String?
  emailVerified  DateTime?
  image          String?
  accounts       Account[]
  sessions       Session[]
  bookings       Booking[]   // ✅ added relation
}

model Account {
  id                String  @id @default(cuid())
  userId            String
  type              String
  provider          String
  providerAccountId String
  refresh_token     String?
  access_token      String?
  expires_at        Int?
  token_type        String?
  scope             String?
  id_token          String?
  session_state     String?

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerAccountId])
}

model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}

model VerificationToken {
  identifier String
  token      String   @unique
  expires    DateTime

  @@unique([identifier, token])
}

model Booking {
  id        String   @id @default(cuid())
  userId    String?
  pickup    String
  dropoff   String
  rideType  String
  fare      Float
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  user User? @relation(fields: [userId], references: [id])
}
'@ | Out-File -Encoding UTF8 "prisma\schema.prisma"

Write-Host "⚡ Step 3: Run Prisma migration..."
npx prisma migrate dev --name fix-booking-relation --skip-seed

Write-Host "✅ Booking schema fixed!"
