import type { NextApiRequest, NextApiResponse } from "next";
import { PrismaClient } from "@prisma/client"
import bcrypt from "bcrypt"

const prisma = new PrismaClient()

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "POST") return res.status(405).end()
  const { email, password, name } = req.body
  const hashed = await bcrypt.hash(password, 10)
  try {
    const user = await prisma.user.create({
      data: { email, name, hashedPassword: hashed },
    })
    res.status(200).json(user)
  }catch {
    res.status(400).json({ error: "User already exists" })
  }
}


