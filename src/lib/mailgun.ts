import formData from "form-data";
import Mailgun from "mailgun.js";
const mg = new Mailgun(formData);
export const mailgun = mg.client({ username: "api", key: process.env.MAILGUN_API_KEY! });
export async function sendEmail(to: string, subject: string, html: string) {
  const domain = process.env.MAILGUN_DOMAIN!;
  const from = process.env.MAILGUN_FROM!;
  return mailgun.messages.create(domain, { from, to, subject, html });
}
