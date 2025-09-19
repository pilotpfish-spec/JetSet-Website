import { NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";

export async function POST(req: Request) {
  const { totalCents, customerId } = await req.json();

  const pi = await stripe.paymentIntents.create({
    amount: totalCents,
    currency: "usd",
    customer: customerId,
    automatic_payment_methods: { enabled: true },
    capture_method: "automatic"
  });

  return NextResponse.json({ clientSecret: pi.client_secret });
}
