require "minitest/autorun"
require_relative 'solution'

class Test < Minitest::Test
  def setup
    @jigsaw = JurassicJigsaw.new
  end

  def test_solution_using_small_puzzle_input
    @jigsaw.setup(puzzle_input: "small_puzzle_input.txt")
    @jigsaw.solve

    assert_equal 20899048083289, @jigsaw.corner_tiles.map(&:id).reduce(&:*)
    assert_equal 273, @jigsaw.image.water_roughness
  end

  def test_solution_using_large_puzzle_input
    @jigsaw.setup(puzzle_input: "large_puzzle_input.txt")
    @jigsaw.solve

    assert_equal 108603771107737, @jigsaw.corner_tiles.map(&:id).reduce(&:*)
    assert_equal 2129, @jigsaw.image.water_roughness
  end
end