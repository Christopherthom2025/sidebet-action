import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "SideBet Action - Golf Scoring & Betting",
  description: "Track scores, manage bets, and compete with friends on the golf course",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}