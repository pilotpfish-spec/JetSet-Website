import dynamic from "next/dynamic";
const BookingWizard = dynamic(()=>import("../../components/BookingWizard"), { ssr: false });

export default function BookingPage() {
  return (
    <div>
      <h1 style={{fontSize:"24px", fontWeight:600, marginBottom:16}}>Book your ride</h1>
      <BookingWizard />
    </div>
  );
}
