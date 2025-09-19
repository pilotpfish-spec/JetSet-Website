import { NextResponse } from "next/server";
import { sendEmail } from "@/lib/mailgun";

export async function POST(req: Request) {
  const { to, summaryHtml } = await req.json();
  try {
    const result = await sendEmail(to, "Your JetSet Direct Booking", summaryHtml);
    if (!result?.id) throw new Error("Mailgun did not return message id");
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ ok: false, error: "Email not sent. Please try again." }, { status: 502 });
  }
}
