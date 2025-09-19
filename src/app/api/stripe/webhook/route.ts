import { NextResponse } from "next/server"
import Stripe from "stripe"

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  
})

export async function POST(req: Request) {
  const sig = req.headers.get("stripe-signature") as string
  const text = await req.text()

  try {
    stripe.webhooks.constructEvent(
      text,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err: unknown) {
    if (err instanceof Error) {
      return new NextResponse(`Webhook Error: ${err.message}`, { status: 400 })
    }
    return new NextResponse("Webhook Error: Unknown", { status: 400 })
  }

  // TODO: mark booking paid/failed + send emails
  return NextResponse.json({ received: true })
}
