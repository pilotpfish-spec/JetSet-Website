import { NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";

export async function POST(req: Request) {
  const sig = req.headers.get("stripe-signature")!;
  const text = await req.text();
  let event;
  try {
    event = stripe.webhooks.constructEvent(text, sig, process.env.STRIPE_WEBHOOK_SECRET!);
  } catch (err: any) {
    return new NextResponse(`Webhook Error: ${err.message}`, { status: 400 });
  }

  // TODO: mark booking paid/failed + send emails
  return NextResponse.json({ received: true });
}
