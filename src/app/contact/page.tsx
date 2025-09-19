export default function Contact() {
  return (
    <main className="max-w-4xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">Contact JetSet Direct</h1>
      <form className="grid gap-3">
        <input className="border rounded p-2" placeholder="Name" required />
        <input className="border rounded p-2" placeholder="Email" type="email" required />
        <input className="border rounded p-2" placeholder="Phone" />
        <textarea className="border rounded p-2" placeholder="Message" rows={5} />
        <button className="px-5 py-3 rounded text-[#0F1F39]" style={{ background: "#FBC02D" }}>Submit</button>
      </form>
      <div className="mt-8 aspect-video rounded overflow-hidden">
        <iframe title="Coverage" width="100%" height="100%" loading="lazy"
          src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d857879.629!2d-97.5!3d32.8!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x864e82c6%3A0x9c429f!2sDallas%2FFort%20Worth%20Metroplex!5e0!3m2!1sen!2sus!4v000000000"
          referrerPolicy="no-referrer-when-downgrade" />
      </div>
    </main>
  );
}
