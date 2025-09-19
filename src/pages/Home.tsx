import React from "react"
import Link from "next/link"

export default function Home() {
  return (
    <div>
      <h1>Welcome to JetSet Direct</h1>
      <nav>
        <ul>
          <li>
            <Link href="/Booking">Book a Ride</Link>
          </li>
          <li>
            <Link href="/Login">Login</Link>
          </li>
        </ul>
      </nav>
    </div>
  )
}
