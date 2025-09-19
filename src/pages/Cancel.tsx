import React from "react"
import Link from "next/link"

export default function Cancel() {
  return (
    <div>
      <h1>Payment Canceled ❌</h1>
      <p>Your booking was not completed.</p>
      <Link href="/">Try Again</Link>
    </div>
  )
}
