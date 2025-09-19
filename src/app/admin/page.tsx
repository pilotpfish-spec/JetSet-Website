import React from "react";

export default function AdminHome() {
  return (
    <main className="p-6">
      <h1 className="text-2xl font-semibold mb-4">Admin</h1>
      <ul className="list-disc pl-6 space-y-1">
        <li>Bookings/Quotes (searchable)</li>
        <li>Analytics dashboards</li>
        <li>Pricing Configuration (Draft &rarr; Preview &rarr; Publish &rarr; Rollback)</li>
        <li>Audit log</li>
      </ul>
    </main>
  );
}
