class JurassicJigsaw
  attr_reader :tiles,
              :grid,
              :dimensions

  def initialize
    @tiles = []
  end

  def setup(puzzle_input:)
    current_tile = nil

    File.readlines(puzzle_input).each do |line|
      line.strip!
      next if line.empty?

      if id = line.strip.match(/Tile (\d+):/)&.captures&.first
        current_tile = Tile.new(id: id.to_i)
        @tiles.push(current_tile)
        next
      end

      current_tile.orientation.data.push(line.chars)
    end

    @dimensions = Math.sqrt(tiles.size)
    @grid       = Array.new(@dimensions){ Array.new(@dimensions) }
  end

  def solve
    set_neighbours
    assemble_tiles
  end

  def set_neighbours
    tiles.each { |tile| tile.neighbours = (tiles - [tile]).select { |t| t.interlock_with?(tile) } }
  end

  def assemble_tiles
    assemble_tile(tile: starting_tile, row: 0, col: 0)
  end

  def assemble_tile(tile:, row:, col:)
    return if row >= dimensions || col >= dimensions

    @grid[row][col] = tile

    tile.neighbours.each do |neighbour|
      next if @grid.flatten.include?(neighbour)
      if neighbour.orientation = neighbour.orientations.find { |o| tile.orientation.right_interlock?(o) }
        assemble_tile(tile: neighbour, row: row, col: col + 1)
      elsif neighbour.orientation = neighbour.orientations.find { |o| tile.orientation.bottom_interlock?(o) }
        assemble_tile(tile: neighbour, row: row + 1, col: col)
      end
    end
  end

  def corner_tiles
    tiles.select { |tile| tile.neighbours.count == 2 }
  end

  def starting_tile
    tile = corner_tiles.sample
    tile.orientation =
      tile.orientations.find do |o| 
        tile.neighbours.all? do |neighbour| 
          neighbour.orientations.any? do |neighbour_orientation| 
            o.right_interlock?(neighbour_orientation) || 
            o.bottom_interlock?(neighbour_orientation)
          end
        end
      end

    tile
  end

  def image
    @image ||= Image.new(orientation: Orientation.new(data: 
      @grid
        .map { |row| row.map { |tile| tile.orientation.strip_borders.data }}
        .flat_map(&:transpose)
        .map(&:flatten)
    ))
  end

  module Orientable
    def orientations
      return @orientations if defined?(@orientations)

      current_orientation = @orientation
      @orientations       = [@orientation, @orientation.flip_horizontally]

      3.times do
        current_orientation = current_orientation.rotate
        @orientations.concat([current_orientation, current_orientation.flip_horizontally])
      end

      @orientations
    end
  end

  class Orientation
    attr_accessor :data

    def initialize(data: [])
      @data = data 
    end

    def dimensions
      data.size
    end

    def rotate
      klass.new(data: data.transpose.map(&:reverse))
    end

    def flip_horizontally
      klass.new(data: data.map(&:reverse))
    end

    def flip_vertically
      klass.new(data: data.reverse)
    end

    def strip_borders
      klass.new(data: data.dup[1..-2].map { |row| row.slice!(1..-2) })
    end

    def right_interlock?(orientation)
      right_border == orientation.left_border
    end

    def bottom_interlock?(orientation)
      bottom_border == orientation.top_border
    end

    def borders
      @borders ||= [ 
        top_border,
        right_border,
        bottom_border,
        left_border
      ]
    end

    def top_border
      data.first
    end

    def bottom_border
      data.last
    end

    def left_border
      data.transpose.first
    end

    def right_border
      data.transpose.last
    end

    def to_s
      data.each do |row|
        puts row.join
      end
    end

    private
      def klass
        self.class
      end
  end

  class Tile
    include Orientable

    attr_accessor :id,
                  :orientation,
                  :neighbours

    def initialize(id:)
      @id                  = id
      @orientation         = Orientation.new
      @neighbours          = []
    end

    def interlock_with?(tile)
      self.orientations
        .map(&:borders)
        .flatten(1)
        .intersection(tile.orientations.map(&:borders).flatten(1))
        .any?
    end
  end

  class Image
    include Orientable

    attr_reader :orientation

    def initialize(orientation:)
      @orientation = orientation
    end

    def sea_monsters
      return @sea_monsters if defined?(@sea_monsters)

      @sea_monsters = []
      orientations.each do |o|
        for row_index in 0..(o.dimensions - SeaMonster::Pattern.height - 1) do
          for col_index in 0..(o.dimensions - SeaMonster::Pattern.width - 1) do
            if SeaMonster::Pattern.coordinates.all? { |x, y| o.data[row_index + x][col_index + y].eql?("#") }
              @sea_monsters.push(SeaMonster.new(row: row_index, col: col_index))
            end
          end
        end

        break unless @sea_monsters.count.zero?
      end

      @sea_monsters
    end

    def water_roughness
      orientation.data.flatten.count("#") - 
      (sea_monsters.count * SeaMonster::Pattern.coordinates.count)
    end

    def to_s
      orientation.to_s
    end

    class SeaMonster
      attr_reader :coordinates

      def initialize(row:, col:)
        @coordinates = Pattern.coordinates.map { |coord| [coord.first + row, coord.last + col] }
      end

      # [
      #   ["?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","?","#","?"],
      #   ["#","?","?","?","?","#","#","?","?","?","?","#","#","?","?","?","?","#","#","#"],
      #   ["?","#","?","?","#","?","?","#","?","?","#","?","?","#","?","?","#","?","?","?"]
      # ]
      class Pattern
        class << self
          def coordinates
            [
              [0, 18], 
              [1,0], [1,5], [1,6], [1,11], [1,12], [1,17], [1,18], [1,19], 
              [2,1], [2,4], [2,7], [2,10], [2,13], [2,16]
            ]
          end

          def width
            coordinates.max_by(&:last).first
          end

          def height
            coordinates.max_by(&:first).first
          end
        end
      end
    end
  end
end