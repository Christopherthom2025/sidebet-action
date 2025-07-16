import Link from "next/link";

export default function HomePage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-8 bg-gradient-to-b from-green-50 to-green-100">
      <div className="max-w-5xl w-full text-center">
        {/* Logo and Title */}
        <div className="mb-12">
          <h1 className="text-6xl font-bold text-green-800 mb-4">
            ⛳ SideBet Action
          </h1>
          <p className="text-xl text-gray-700">
            Track scores, manage bets, and compete with friends on the golf course
          </p>
        </div>

        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-4xl mb-4">📊</div>
            <h3 className="text-xl font-semibold mb-2">Live Scoring</h3>
            <p className="text-gray-600">
              Track scores in real-time as you play
            </p>
          </div>
          
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-4xl mb-4">💰</div>
            <h3 className="text-xl font-semibold mb-2">Bet Management</h3>
            <p className="text-gray-600">
              Skins, Nassau, Match Play and more
            </p>
          </div>
          
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-4xl mb-4">🏆</div>
            <h3 className="text-xl font-semibold mb-2">Leaderboards</h3>
            <p className="text-gray-600">
              See who's winning across all games
            </p>
          </div>
        </div>

        {/* CTA Buttons */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link
            href="/auth/signup"
            className="bg-green-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-green-700 transition"
          >
            Get Started
          </Link>
          <Link
            href="/auth/login"
            className="bg-white text-green-600 border-2 border-green-600 px-8 py-3 rounded-lg font-semibold hover:bg-green-50 transition"
          >
            Sign In
          </Link>
        </div>
      </div>
    </main>
  );
}