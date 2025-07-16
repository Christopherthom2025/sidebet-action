import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { gameId, betId } = await req.json()
    
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Get bet details
    const { data: bet, error: betError } = await supabaseClient
      .from('bets')
      .select('*, bet_participants(*)')
      .eq('id', betId)
      .single()

    if (betError) throw betError

    // Get hole scores for the game
    const { data: scores, error: scoresError } = await supabaseClient
      .from('hole_scores')
      .select('*')
      .eq('game_id', gameId)
      .eq('hole_number', bet.hole_number)

    if (scoresError) throw scoresError

    // Calculate payouts based on bet type
    let payouts = {}
    
    switch (bet.bet_type) {
      case 'skins':
        // Lowest score wins the hole
        const minScore = Math.min(...scores.map(s => s.strokes))
        const winners = scores.filter(s => s.strokes === minScore)
        
        if (winners.length === 1) {
          payouts[winners[0].user_id] = bet.amount * bet.bet_participants.length
        } else {
          // Split pot among tied players
          const splitAmount = (bet.amount * bet.bet_participants.length) / winners.length
          winners.forEach(w => {
            payouts[w.user_id] = splitAmount
          })
        }
        break
        
      case 'nassau':
        // Front 9, Back 9, and Total scoring
        // Implementation depends on current hole
        break
        
      case 'match':
        // Head-to-head match play scoring
        break
    }

    // Update payouts in database
    for (const [userId, payout] of Object.entries(payouts)) {
      await supabaseClient
        .from('bet_participants')
        .update({ payout })
        .eq('bet_id', betId)
        .eq('user_id', userId)
    }

    return new Response(JSON.stringify({ success: true, payouts }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})