import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const email = "demo@jetsetdirect.com";
  const password = "Password123!";
  const name = "Demo User";
  const phone = "555-123-4567";

  // Check if user exists
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    console.log("⚠️ User already exists:", email);
    return;
  }

  // Hash password
  const hashedPassword = await bcrypt.hash(password, 10);

  // Create user
  const user = await prisma.user.create({
    data: {
      email,
      name,
      phone,
      hashedPassword,
    },
  });

  console.log("✅ Dummy user created:", user);
}

main()
  .then(() => prisma.$disconnect())
  .catch((e) => {
    console.error("❌ Error seeding user:", e);
    prisma.$disconnect();
    process.exit(1);
  });
