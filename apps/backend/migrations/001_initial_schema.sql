-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    handicap INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    PRIMARY KEY (id)
);

-- Games table
CREATE TABLE public.games (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    course_name TEXT NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Game participants
CREATE TABLE public.game_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    game_id UUID REFERENCES public.games(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(game_id, user_id)
);

-- Holes scoring
CREATE TABLE public.hole_scores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    game_id UUID REFERENCES public.games(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id),
    hole_number INTEGER NOT NULL CHECK (hole_number BETWEEN 1 AND 18),
    strokes INTEGER NOT NULL CHECK (strokes > 0),
    par INTEGER NOT NULL CHECK (par BETWEEN 3 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(game_id, user_id, hole_number)
);

-- Bets table
CREATE TABLE public.bets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    game_id UUID REFERENCES public.games(id) ON DELETE CASCADE,
    hole_number INTEGER CHECK (hole_number BETWEEN 1 AND 18),
    bet_type TEXT NOT NULL CHECK (bet_type IN ('skins', 'nassau', 'match', 'custom')),
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Bet participants
CREATE TABLE public.bet_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    bet_id UUID REFERENCES public.bets(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id),
    payout DECIMAL(10,2) DEFAULT 0,
    UNIQUE(bet_id, user_id)
);
-- RLS Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hole_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bet_participants ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view all profiles" ON public.profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Games policies
CREATE POLICY "Users can view games they participate in" ON public.games
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.game_participants
            WHERE game_participants.game_id = games.id
            AND game_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create games" ON public.games
    FOR INSERT WITH CHECK (auth.uid() = created_by);

-- Game participants policies
CREATE POLICY "Users can view participants in their games" ON public.game_participants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.game_participants gp
            WHERE gp.game_id = game_participants.game_id
            AND gp.user_id = auth.uid()
        )
    );

-- Hole scores policies
CREATE POLICY "Users can view scores in their games" ON public.hole_scores
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.game_participants
            WHERE game_participants.game_id = hole_scores.game_id
            AND game_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own scores" ON public.hole_scores
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own scores" ON public.hole_scores
    FOR UPDATE USING (auth.uid() = user_id);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_games_updated_at BEFORE UPDATE ON public.games
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();