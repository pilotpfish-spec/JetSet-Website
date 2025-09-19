param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

$schemaPath = Join-Path $ProjectRoot "prisma\schema.prisma"

# 1) Compose the schema as lines (avoid here-string edge cases)
$lines = @(
  'generator client { provider = "prisma-client-js" }',
  '',
  'datasource db {',
  '  provider = "sqlite"',
  '  url      = "file:./dev.db"',
  '}',
  '',
  'enum Role { USER ADMIN }',
  'enum BookingStatus { PENDING CONFIRMED CANCELLED REFUNDED }',
  'enum Mode { TO_AIRPORT FROM_AIRPORT POINT_TO_POINT }',
  'enum PricingStatus { DRAFT PUBLISHED }',
  '',
  'model User {',
  '  id               String   @id @default(cuid())',
  '  email            String   @unique',
  '  passwordHash     String',
  '  name             String?',
  '  phone            String?',
  '  stripeCustomerId String?',
  '  role             Role     @default(USER)',
  '  createdAt        DateTime @default(now())',
  '  lastLogin        DateTime?',
  '  addresses        Address[]',
  '  paymentMethods   PaymentMethod[]',
  '  quotes           Quote[]',
  '  bookings         Booking[]',
  '  auditLogs        AuditLog[] @relation("UserAuditLogs")',
  '}',
  '',
  'model Address {',
  '  id          String   @id @default(cuid())',
  '  user        User?    @relation(fields: [userId], references: [id])',
  '  userId      String?',
  '  label       String?',
  '  fullAddress String',
  '  lat         Float',
  '  lng         Float',
  '  isDefault   Boolean  @default(false)',
  '  lastUsed    DateTime @default(now())',
  '}',
  '',
  'model PaymentMethod {',
  '  id         String  @id @default(cuid())',
  '  user       User    @relation(fields: [userId], references: [id])',
  '  userId     String',
  '  stripePmId String  @unique',
  '  brand      String',
  '  last4      String',
  '  expMonth   Int',
  '  expYear    Int',
  '  isDefault  Boolean @default(false)',
  '}',
  '',
  'model Quote {',
  '  id               String   @id @default(cuid())',
  '  user             User?    @relation(fields: [userId], references: [id])',
  '  userId           String?',
  '  mode             Mode',
  '  originAddress    String',
  '  originLat        Float',
  '  originLng        Float',
  '  destAddress      String',
  '  destLat          Float',
  '  destLng          Float',
  '  distanceMeters   Int',
  '  durationSeconds  Int',
  '  breakdownJson    Json',
  '  totalCents       Int',
  '  expiresAt        DateTime',
  '  createdAt        DateTime @default(now())',
  '}',
  '',
  'model Booking {',
  '  id                     String         @id @default(cuid())',
  '  user                   User           @relation(fields: [userId], references: [id])',
  '  userId                 String',
  '  quote                  Quote          @relation(fields: [quoteId], references: [id])',
  '  quoteId                String',
  '  status                 BookingStatus  @default(PENDING)',
  '  pickupAt               DateTime',
  '  pax                    Int',
  '  bags                   Int',
  '  notes                  String?',
  '  totalCents             Int',
  '  stripePaymentIntentId  String?',
  '  createdAt              DateTime       @default(now())',
  '}',
  '',
  'model PricingConfig {',
  '  id               String         @id @default(cuid())',
  '  version          Int',
  '  status           PricingStatus  @default(DRAFT)',
  '  toFromAirport    Json',
  '  pointToPoint     Json',
  '  airportOverrides Json?',
  '  createdBy        User           @relation(fields: [createdByUserId], references: [id])',
  '  createdByUserId  String',
  '  publishedAt      DateTime?',
  '  createdAt        DateTime       @default(now())',
  '}',
  '',
  'model AuditLog {',
  '  id           String   @id @default(cuid())',
  '  actor        User?    @relation("UserAuditLogs", fields: [actorUserId], references: [id])',
  '  actorUserId  String?',
  '  action       String',
  '  targetType   String',
  '  targetId     String?',
  '  metadata     Json?',
  '  createdAt    DateTime @default(now())',
  '}'
)

# 2) Write as UTF-8 *without BOM*
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($schemaPath, ($lines -join "`r`n"), $utf8NoBom)

# 3) Run prisma format first (clear validation), then generate
$npxCmd = Join-Path $env:ProgramFiles "nodejs\npx.cmd"
if (!(Test-Path $npxCmd)) { throw "npx.cmd not found at $npxCmd" }

& $npxCmd prisma format
if ($LASTEXITCODE -ne 0) {
  throw "prisma format failed (code $LASTEXITCODE)"
}

& $npxCmd prisma generate
if ($LASTEXITCODE -ne 0) {
  throw "prisma generate failed (code $LASTEXITCODE)"
}

Write-Host "OK: schema.prisma reset (UTF-8 no BOM), validated, and Prisma client generated."
