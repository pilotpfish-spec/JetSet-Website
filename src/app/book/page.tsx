import { redirect } from "next/navigation";

export default function BookAlias() {
  // Alias /book -> /booking
  redirect("/booking");
}
