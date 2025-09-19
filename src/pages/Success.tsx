import React from "react"
import Link from "next/link"

export default function Success() {
  return (
    <div>
      <h1>Payment Successful 🎉</h1>
      <p>Your booking has been confirmed.</p>
      <Link href="/">Return Home</Link>
    </div>
  )
}
