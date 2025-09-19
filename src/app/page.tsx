import Hero from "@/components/Hero";
import QuoteForm from "@/components/QuoteForm";

export default function Landing() {
  return (
    <main>
      <Hero />
      <section className="py-12 bg-[#F5F6F8]">
        <div className="max-w-5xl mx-auto">
          <QuoteForm />
        </div>
      </section>
    </main>
  );
}

