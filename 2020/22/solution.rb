class Player
  attr_reader :name, 
              :deck

  def initialize(name:)
    @name = name
    @deck = []
  end

  def play
    deck.shift
  end

  def score
    deck.reverse
      .each_with_index
      .reduce(0) { |acc, (card, index)| acc + (card * index.next) }
  end

  def player_1?
    name == "Player 1"
  end

  def player_2?
    name == "Player 2"
  end
end


class Game
  attr_reader :player_1,
              :player_2,
              :player_1_card,
              :player_2_card,
              :rounds,
              :winner

  def initialize
    @player_1 = Player.new(name: "Player 1")
    @player_2 = Player.new(name: "Player 2")
    @rounds   = []
  end

  def setup(puzzle_input:)
    current_player = nil

    File.readlines(puzzle_input).each do |line|
      line.strip!
      next if line.empty?

      if line.include?("Player")
        current_player = player_1 if line.include?("Player 1")
        current_player = player_2 if line.include?("Player 2")
        next
      end
      
      current_player.deck.push(line.to_i)
    end
  end

  def play
    while winner.nil? 
      play_round
      determine_winner
    end
  end

  def determine_winner
    return unless winner.nil?
    @winner = player_1 if player_2.deck.empty?
    @winner = player_2 if player_1.deck.empty?
  end

  def results
    puts "== Post-game results =="
    puts "Player 1's deck: #{player_1.deck.join(', ')}"
    puts "Player 2's deck: #{player_2.deck.join(', ')}"
    puts "Winning player's score: #{winner.score}"
  end
end


class Combat < Game
  def play_round
    current_round = [player_1.deck.dup, player_2.deck.dup]
    rounds.push(current_round)

    player_1_card, player_2_card = player_1.play, player_2.play

    player_1_card > player_2_card ?
      player_1.deck.concat([player_1_card, player_2_card]) :
      player_2.deck.concat([player_2_card, player_1_card])
  end
end


class RecursiveCombat < Game
  def play_round
    current_round = [player_1.deck.dup, player_2.deck.dup]
    return @winner = player_1 if duplicate_round?(current_round)
    rounds.push(current_round)

    @player_1_card, @player_2_card = player_1.play, player_2.play

    if play_subgame?
      play_subgame
    else
      player_1_card > player_2_card ?
        player_1.deck.concat([player_1_card, player_2_card]) :
        player_2.deck.concat([player_2_card, player_1_card])
    end
  end

  def duplicate_round?(round)
    rounds.any? { |r| r == round }
  end

  def play_subgame?
    player_1_card <= player_1.deck.count && 
    player_2_card <= player_2.deck.count
  end

  def play_subgame
    subgame = RecursiveCombat.new
    subgame.player_1.deck.concat(player_1.deck.first(player_1_card))
    subgame.player_2.deck.concat(player_2.deck.first(player_2_card))
    subgame.play

    player_1.deck.concat([player_1_card, player_2_card]) if subgame.winner.player_1?
    player_2.deck.concat([player_2_card, player_1_card]) if subgame.winner.player_2?
  end
end