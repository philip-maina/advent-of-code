class AllergenAssessor
  attr_reader :foods,
              :allergens,
              :ingredients

  def initialize
    @foods       = []
    @ingredients = []
    @allergens   = {}
  end
              
  def assess!(puzzle_input:)
    File.readlines(puzzle_input).each do |line|
      food_allergens, food_ingredients = parse_line(line)
      @foods.push(food_ingredients) 
      @ingredients     |= food_ingredients
      food_ingredients -= allergens.select { |_, val| val&.one? }.values

      food_allergens.each do |allergen|
        next if allergens[allergen]&.one?

        @allergens[allergen] ||= food_ingredients
        @allergens[allergen] &=  food_ingredients
        update_allergens(allergen) if allergens[allergen].one?
      end
    end
  end

  def allergenic_ingredients
    allergens.sort.to_h.values
  end

  def inert_ingredients
    ingredients - allergens.values.flatten
  end

  def inert_ingredients_frequency
    inert_ingredients.reduce(0) { |acc, ingredient| acc + foods.flatten.count(ingredient) }
  end

  private
    def update_allergens(allergen)
      allergens.each do |key, val| 
        next if key == allergen
        next if val.one?
        
        @allergens[key] -= allergens[allergen]
        update_allergens(key) if allergens[key].one?
      end
    end

    def parse_line(line)
      matches          = line.strip.match(/(.*)\(contains (.*)\)/).captures
      food_ingredients = matches.first.split
      food_allergens   = matches.last.split(", ")

      [food_allergens, food_ingredients]
    end
end