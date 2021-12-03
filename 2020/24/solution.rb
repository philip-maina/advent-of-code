class Tile
  @table  = {}

  attr_reader :colour,
              :coordinate,
              :neighbours

  class << self
    def table
      @table
    end

    def all
      @table.values
    end

    def create_or_find_by(attributes)
      find_by(attributes) || create(attributes)
    end

    def create(attributes)
      @table[attributes[:coordinate].to_s] = new(coordinate: attributes[:coordinate])
    end

    def find_by(attributes)
      @table[attributes[:coordinate].to_s]
    end

    def where(conditions)
      filtered = all
      filtered.select! { |tile| tile.colour == conditions[:colour] } if conditions[:colour]
      filtered.select! { |tile| tile.coordinate == conditions[:coordinate] } if conditions[:coordinate]

      filtered
    end
  end
                
  def initialize(coordinate:, neighbours: [])
    @colour     = :white
    @coordinate = coordinate
    @neighbours = neighbours
  end

  # For Part Two, the tiles of interest are the black tiles and their neighbouring tiles.
  def flip!
    @colour = white? ? :black : :white
    add_neighbours if black? && neighbours.count < 6
  end

  def black?
    colour == :black
  end

  def white?
    colour == :white
  end

  private
    def add_neighbours
      self.coordinate.neighbours.each do |coord|
        neighbour = self.class.create_or_find_by(coordinate: coord)

        unless neighbours.include?(neighbour)
          neighbours.push(neighbour)
          neighbour.neighbours.push(self)
        end
      end
    end
end


class Coordinate
  attr_reader :x, :y

  class << self
    def origin
      self.new(x: 0, y: 0)
    end
  end

  def initialize(x:, y:)
    @x, @y = x, y
  end

  def +(other)
    Coordinate.new(
      x: x + other.x,
      y: y + other.y
    )
  end

  def ==(other)
    self.class == other.class &&
    x == other.x &&
    y == other.y
  end
  alias :eql? :==

  def neighbours
    @neighbours ||= CompassDirection::COORDINATE_MAPPING.values.map do |coordinate| 
      self + coordinate
    end
  end

  def to_s
    "(#{x}, #{y})"
  end
end


class CompassDirection
  COORDINATE_MAPPING = {
    "e"  => Coordinate.new(x:  2, y:  0),
    "w"  => Coordinate.new(x: -2, y:  0),
    "ne" => Coordinate.new(x:  1, y:  1.5),
    "nw" => Coordinate.new(x: -1, y:  1.5),
    "se" => Coordinate.new(x:  1, y: -1.5),
    "sw" => Coordinate.new(x: -1, y: -1.5)
  }
  INITIALS = COORDINATE_MAPPING.keys

  attr_reader :initial

  def initialize(initial:)
    @initial = initial
  end

  def to_coordinate
    COORDINATE_MAPPING[initial]
  end

  class Series
    attr_reader :compass_directions
  
    class << self
      def from_initials(initials)
        compass_directions = []
    
        while !initials.empty?
          match = INITIALS.detect { |initial| /^#{initial}/.match?(initials) }
          initials.gsub!(/^#{match}/, '')
          compass_directions.push(CompassDirection.new(initial: match))
        end
    
        new(compass_directions: compass_directions)
      end
    end

    def initialize(compass_directions:)
      @compass_directions = compass_directions
    end
  
    def to_coordinate
      compass_directions.reduce(Coordinate.origin) do |acc, compass_direction|
        acc + compass_direction.to_coordinate
      end
    end
  end
end


module LobbyLayout
  class PartOne
    def self.run!
      File.readlines('puzzle_input_2.txt').each do |line|
        coordinate = CompassDirection::Series.from_initials(line.strip).to_coordinate
        tile = Tile.create_or_find_by(coordinate: coordinate)
        tile.flip!
      end

      p "Puzzle Answer:"
      p Tile.where(colour: :black).count
    end
  end

  class PartTwo
    def self.run!(no_of_days:)
      1.upto(no_of_days) do |day|
        Tile.all.select do |tile|
          (tile.black? && ((tile.neighbours.count(&:black?) == 0) || (tile.neighbours.count(&:black?) > 2))) || 
          (tile.white? && (tile.neighbours.count(&:black?) == 2))
        end.each(&:flip!)

        p "Day #{day}: #{Tile.where(colour: :black).count}"
      end
    end
  end
end


LobbyLayout::PartOne.run!
LobbyLayout::PartTwo.run!(no_of_days: 100)