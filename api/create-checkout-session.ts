import Stripe from "stripe"
import type { NextApiRequest, NextApiResponse } from "next"

// Use environment variable for secret key
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY as string, {
  apiVersion: "2025-08-27.basil", // supported version
})

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" })
  }

  try {
    const { amount } = req.body

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      mode: "payment",
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: { name: "JetSet Direct Ride" },
            unit_amount: amount,
          },
          quantity: 1,
        },
      ],
      success_url: `${req.headers.origin}/success`,
      cancel_url: `${req.headers.origin}/cancel`,
    })

    res.status(200).json({ id: session.id })
  } catch (error: any) {
    console.error(error)
    res.status(500).json({ error: "Failed to create checkout session" })
  }
}
