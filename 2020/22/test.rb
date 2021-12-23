require "minitest/autorun"
require_relative 'solution'

class Test < Minitest::Test
  def test_combat_using_small_puzzle_input
    @game = Combat.new
    @game.setup(puzzle_input: "small_puzzle_input.txt")
    @game.play

    assert_equal 306, @game.winner.score
  end

  def test_combat_using_large_puzzle_input
    @game = Combat.new
    @game.setup(puzzle_input: "large_puzzle_input.txt")
    @game.play

    assert_equal 34005, @game.winner.score
  end

  def test_recursive_combat_using_small_puzzle_input
    @game = RecursiveCombat.new
    @game.setup(puzzle_input: "small_puzzle_input.txt")
    @game.play

    assert_equal 291, @game.winner.score
  end

  def test_recursive_combat_using_large_puzzle_input
    @game = RecursiveCombat.new
    @game.setup(puzzle_input: "large_puzzle_input.txt")
    @game.play

    assert_equal 32731, @game.winner.score
  end

  def test_recursive_combat_for_infinite_prevention_rule
    @game = RecursiveCombat.new
    @game.setup(puzzle_input: "infinite_prevention_puzzle_input.txt")
    @game.play

    assert_equal 105, @game.winner.score
  end
end