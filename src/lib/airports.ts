export type Airport = { code: string; name: string; display: string };
export const AIRPORTS: Airport[] = [
  { code: "DFW", name: "Dallas/Fort Worth International Airport", display: "DFW - Dallas/Fort Worth" },
  { code: "DAL", name: "Dallas Love Field", display: "DAL - Dallas Love Field" },
  { code: "IAH", name: "George Bush Intercontinental", display: "IAH - Houston Intercontinental" },
  { code: "HOU", name: "William P. Hobby", display: "HOU - Houston Hobby" },
  { code: "AUS", name: "Austin-Bergstrom International", display: "AUS - Austin" },
  { code: "SAT", name: "San Antonio International", display: "SAT - San Antonio" },
  { code: "OKC", name: "Will Rogers World Airport", display: "OKC - Oklahoma City" },
  { code: "SHV", name: "Shreveport Regional", display: "SHV - Shreveport" }
];
export const airportDisplay = (code: string) => AIRPORTS.find(a => a.code === code)?.display ?? code;
export const airportFullName = (code: string) => AIRPORTS.find(a => a.code === code)?.name ?? code;
