require "minitest/autorun"
require_relative 'solution'

class Test < Minitest::Test
  def setup
    Tile.clear
  end

  def test_using_puzzle_input_1 
    LobbyLayout::PartOne.run!(puzzle_input: 'puzzle_input_1.txt')
    assert_equal 10, Tile.where(colour: :black).count

    LobbyLayout::PartTwo.run!(no_of_days: 100)
    assert_equal 2208, Tile.where(colour: :black).count
  end

  def test_using_puzzle_input_2
    LobbyLayout::PartOne.run!(puzzle_input: 'puzzle_input_2.txt')
    assert_equal 282, Tile.where(colour: :black).count

    LobbyLayout::PartTwo.run!(no_of_days: 100)
    assert_equal 3445, Tile.where(colour: :black).count
  end
end