# 32-fix-db.ps1
# Reset Prisma schema to Postgres version, format, and migrate cleanly.

Write-Host "==> Writing fixed Postgres schema..."
@'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id              String   @id @default(cuid())
  email           String   @unique
  hashedPassword  String
  name            String?
  phone           String?
  stripeCustomerId String?
  role            Role     @default(USER)
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  accounts        Account[]
  sessions        Session[]
  savedAddresses  SavedAddress[]
  bookings        Booking[]
}

model Account {
  id                 String  @id @default(cuid())
  userId             String
  type               String
  provider           String
  providerAccountId  String
  refresh_token      String? @db.Text
  access_token       String? @db.Text
  expires_at         Int?
  token_type         String?
  scope              String?
  id_token           String? @db.Text
  session_state      String?

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}

model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}

model SavedAddress {
  id        String   @id @default(cuid())
  userId    String
  label     String
  address   String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}

model Booking {
  id            String   @id @default(cuid())
  userId        String
  origin        String
  dest          String
  fareCents     Int
  status        String   @default("PENDING")
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  user User @relation(fields: [userId], references: [id])
}

enum Role {
  USER
  ADMIN
}
'@ | Set-Content -Path "prisma\schema.prisma" -Encoding UTF8

Write-Host "==> Running prisma format..."
npx prisma format

Write-Host "==> Resetting and migrating Postgres DB..."
npx prisma migrate reset --force

Write-Host "`n✅ Done. Your schema is now Postgres-based and database reset is complete."
Write-Host "👉 Run: npx prisma studio  (to inspect User, Account, Session, SavedAddress, Booking)"
