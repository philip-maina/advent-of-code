class Game
  def initialize(puzzle_input)
    @cups = Cup.from_labels(puzzle_input)
    @cups.map(&:label).max.next.upto(1000000) { |label| @cups.push(Cup.new(label)) }
    @crab = Player.new
  end

  def play
    1.upto(10000000) do |i| 
      p "-- move #{i} --" 
      @cups = @crab.perform_move!(@cups)
    end

    p "-- final --"
    p @cups.map.with_index { |cup, index| index.zero? ? "(#{cup.label})" : cup.label }.join(" ")

    p "Puzzle Answer:"
    p 
  end

  class Cup
    attr_reader :label

    def self.from_labels(labels)
      labels.chars.map { |label| new(label.to_i) }
    end

    def initialize(label)
      @label = label
    end
  end


  class Player
    def perform_move!(cups)
      p "cups: " + cups.map.with_index { |cup, index| index.zero? ? "(#{cup.label})" : cup.label }.join(" ")
      
      current_cup = cups.first
      picked_cups = cups.slice!(1..3)
      p "pick up: " + picked_cups.map(&:label).join(", ")

      destination_cup_labels = Array.new(3) { |i| current_cup.label - i.next }
      destination_cup_label  = (destination_cup_labels - picked_cups.map(&:label)).max
      destination_cup_label  = cups.max_by(&:label).label if destination_cup_label.zero?
      destination_cup_index  = cups.find_index { |cup| cup.label == destination_cup_label }
      p "destination: #{destination_cup_label}"
      

      cups.insert(destination_cup_index + 1, *picked_cups)
      cups.rotate!
    end
  end
end


game = Game.new("389125467")
game.play