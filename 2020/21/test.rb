require "minitest/autorun"
require_relative 'solution'

class Test < Minitest::Test
  def setup
    @assessor = AllergenAssessor.new
  end

  def test_allergen_assessment_using_small_puzzle_input
    @assessor.assess!(puzzle_input: "small_puzzle_input.txt")

    assert_equal 5, @assessor.inert_ingredients_frequency
    assert_equal "mxmxvkd,sqjhc,fvjkl", @assessor.allergenic_ingredients.join(",")
  end

  def test_allergen_assessment_using_large_puzzle_input
    @assessor.assess!(puzzle_input: "large_puzzle_input.txt")
    
    assert_equal 1958, @assessor.inert_ingredients_frequency
    assert_equal "xxscc,mjmqst,gzxnc,vvqj,trnnvn,gbcjqbm,dllbjr,nckqzsg", @assessor.allergenic_ingredients.join(",")
  end
end