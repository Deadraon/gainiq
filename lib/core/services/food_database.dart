// ─────────────────────────────────────────────────────────────
//  FOOD ITEM MODEL
// ─────────────────────────────────────────────────────────────
class FoodItem {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double costPerServing;
  final String servingSize;
  final List<String> tags;
  final String emoji;
  final String? allergen;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.costPerServing,
    required this.servingSize,
    required this.tags,
    this.emoji = '🍽',
    this.allergen,
  });
}

// ─────────────────────────────────────────────────────────────
//  INDIAN FOOD DATABASE  (80+ items)
//  Diet tags: 'veg', 'egg', 'nonveg'
//  Meal tags: 'breakfast', 'lunch', 'dinner', 'snack'
//  Budget tiers: items range ₹8–₹80 per serving
// ─────────────────────────────────────────────────────────────
const List<FoodItem> indianFoodDB = [

  // ══════════════════════════════════════════════
  //  VEG BREAKFAST
  // ══════════════════════════════════════════════
  FoodItem(name: 'Oats with Milk & Banana', calories: 320, protein: 13, carbs: 52, fat: 6, costPerServing: 22, servingSize: '60g oats + 200ml milk + 1 banana', tags: ['veg', 'breakfast'], emoji: '🥣'),
  FoodItem(name: 'Muesli with Cold Milk & Honey', calories: 350, protein: 12, carbs: 58, fat: 8, costPerServing: 35, servingSize: '50g muesli + 200ml milk', tags: ['veg', 'breakfast'], emoji: '🥣'),
  FoodItem(name: 'Quinoa Veggie Upma', calories: 280, protein: 11, carbs: 45, fat: 7, costPerServing: 40, servingSize: '1 bowl', tags: ['veg', 'breakfast', 'lunch'], emoji: '🥗'),
  FoodItem(name: 'Poha with Peanuts', calories: 270, protein: 8, carbs: 46, fat: 6, costPerServing: 12, servingSize: '1 cup', tags: ['veg', 'breakfast'], emoji: '🍚'),
  FoodItem(name: 'Upma with Veggies', calories: 240, protein: 7, carbs: 42, fat: 6, costPerServing: 14, servingSize: '1 cup', tags: ['veg', 'breakfast'], emoji: '🫕'),
  FoodItem(name: 'Idli (3) + Sambar + Chutney', calories: 290, protein: 10, carbs: 54, fat: 3, costPerServing: 18, servingSize: '3 idlis', tags: ['veg', 'breakfast', 'lunch'], emoji: '🍚'),
  FoodItem(name: 'Moong Dal Chilla (2)', calories: 210, protein: 15, carbs: 28, fat: 4, costPerServing: 14, servingSize: '2 chillas', tags: ['veg', 'breakfast', 'snack'], emoji: '🥞'),
  FoodItem(name: 'Besan Chilla (2)', calories: 230, protein: 13, carbs: 30, fat: 6, costPerServing: 12, servingSize: '2 chillas', tags: ['veg', 'breakfast', 'snack'], emoji: '🥞'),
  FoodItem(name: 'Peanut Butter Toast (2 slices)', calories: 320, protein: 13, carbs: 38, fat: 14, costPerServing: 28, servingSize: '2 whole-wheat slices + 2 tbsp PB', tags: ['veg', 'breakfast', 'snack'], emoji: '🍞'),
  FoodItem(name: 'Banana + Milk', calories: 260, protein: 9, carbs: 46, fat: 5, costPerServing: 20, servingSize: '1 banana + 250ml milk', tags: ['veg', 'breakfast', 'snack'], emoji: '🍌'),
  FoodItem(name: 'Curd with Fruits', calories: 180, protein: 8, carbs: 28, fat: 3, costPerServing: 20, servingSize: '200g curd + seasonal fruit', tags: ['veg', 'breakfast', 'snack'], emoji: '🥛'),
  FoodItem(name: 'Greek Yogurt + Nuts', calories: 200, protein: 18, carbs: 14, fat: 8, costPerServing: 45, servingSize: '200g yogurt + 15g nuts', tags: ['veg', 'breakfast', 'snack'], emoji: '🥛'),
  FoodItem(name: 'Sattu Drink', calories: 180, protein: 10, carbs: 30, fat: 2, costPerServing: 10, servingSize: '40g sattu + water + lemon', tags: ['veg', 'breakfast', 'snack'], emoji: '🥤'),
  FoodItem(name: 'Dalia (Broken Wheat) Porridge', calories: 250, protein: 8, carbs: 48, fat: 3, costPerServing: 10, servingSize: '1 bowl', tags: ['veg', 'breakfast'], emoji: '🥣'),
  FoodItem(name: 'Methi Thepla (2)', calories: 240, protein: 7, carbs: 36, fat: 8, costPerServing: 16, servingSize: '2 theplas', tags: ['veg', 'breakfast', 'lunch'], emoji: '🫓'),
  FoodItem(name: 'Pesarattu (Green Moong Dosa 2)', calories: 220, protein: 14, carbs: 32, fat: 4, costPerServing: 15, servingSize: '2 dosas', tags: ['veg', 'breakfast'], emoji: '🥞'),

  // ══════════════════════════════════════════════
  //  EGG BREAKFAST
  // ══════════════════════════════════════════════
  FoodItem(name: 'Whole Eggs (2) + Toast', calories: 280, protein: 16, carbs: 22, fat: 12, costPerServing: 28, servingSize: '2 eggs + 2 slices', tags: ['egg', 'breakfast'], emoji: '🍳'),
  FoodItem(name: 'Egg White Omelette (4 whites)', calories: 70, protein: 15, carbs: 1, fat: 0.4, costPerServing: 14, servingSize: '4 egg whites', tags: ['egg', 'breakfast'], emoji: '🍳'),
  FoodItem(name: 'Scrambled Eggs (3) + Roti', calories: 380, protein: 22, carbs: 30, fat: 16, costPerServing: 35, servingSize: '3 eggs + 2 rotis', tags: ['egg', 'breakfast'], emoji: '🍳'),
  FoodItem(name: 'Egg Bhurji (3 eggs) + Roti (2)', calories: 400, protein: 24, carbs: 38, fat: 18, costPerServing: 38, servingSize: '3 eggs + 2 rotis', tags: ['egg', 'breakfast', 'dinner'], emoji: '🍳'),
  FoodItem(name: 'Boiled Eggs (3) + Banana', calories: 310, protein: 20, carbs: 28, fat: 12, costPerServing: 30, servingSize: '3 eggs + 1 banana', tags: ['egg', 'breakfast', 'snack'], emoji: '🥚'),

  // ══════════════════════════════════════════════
  //  NON-VEG BREAKFAST
  // ══════════════════════════════════════════════
  FoodItem(name: 'Chicken Keema Paratha (2)', calories: 440, protein: 28, carbs: 44, fat: 16, costPerServing: 55, servingSize: '2 parathas', tags: ['nonveg', 'breakfast', 'lunch'], emoji: '🫓'),
  FoodItem(name: 'Tuna Sandwich (Whole Wheat)', calories: 320, protein: 26, carbs: 34, fat: 8, costPerServing: 50, servingSize: '2 slices + 1 can tuna', tags: ['nonveg', 'breakfast', 'lunch'], emoji: '🥪'),
  FoodItem(name: 'Smoked Salmon & Egg White Wrap', calories: 340, protein: 32, carbs: 24, fat: 12, costPerServing: 120, servingSize: '1 whole wheat wrap', tags: ['nonveg', 'breakfast'], emoji: '🌯'),

  // ══════════════════════════════════════════════
  //  UNIVERSAL BREAKFAST (all diets)
  // ══════════════════════════════════════════════
  FoodItem(name: 'Whey Protein Shake', calories: 130, protein: 25, carbs: 4, fat: 2, costPerServing: 65, servingSize: '1 scoop + 300ml water', tags: ['veg', 'egg', 'nonveg', 'breakfast', 'snack'], emoji: '🥤'),
  FoodItem(name: 'Banana + Peanut Butter', calories: 240, protein: 7, carbs: 36, fat: 9, costPerServing: 22, servingSize: '1 banana + 1 tbsp PB', tags: ['veg', 'egg', 'nonveg', 'snack', 'breakfast'], emoji: '🍌'),

  // ══════════════════════════════════════════════
  //  VEG LUNCH / DINNER
  // ══════════════════════════════════════════════
  FoodItem(name: 'Dal + Rice + Sabzi', calories: 400, protein: 18, carbs: 72, fat: 6, costPerServing: 25, servingSize: '1 cup dal + 1 cup rice + 1 bowl sabzi', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),
  FoodItem(name: 'Rajma + Brown Rice', calories: 400, protein: 20, carbs: 68, fat: 5, costPerServing: 24, servingSize: '1 cup rajma + 1 cup rice', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),
  FoodItem(name: 'Chole + Roti (3)', calories: 430, protein: 18, carbs: 64, fat: 9, costPerServing: 28, servingSize: '1 cup chole + 3 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),
  FoodItem(name: 'Paneer Sabzi + Roti (3)', calories: 480, protein: 26, carbs: 46, fat: 22, costPerServing: 60, servingSize: '150g paneer + 3 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🧀'),
  FoodItem(name: 'Soya Chunks Curry + Rice', calories: 360, protein: 30, carbs: 48, fat: 4, costPerServing: 22, servingSize: '50g dry soya + 1 cup rice', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),
  FoodItem(name: 'Palak Paneer + Roti (2)', calories: 430, protein: 22, carbs: 42, fat: 20, costPerServing: 55, servingSize: '150g + 2 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🥬'),
  FoodItem(name: 'Mixed Veg Khichdi', calories: 350, protein: 14, carbs: 58, fat: 7, costPerServing: 20, servingSize: '1 large bowl', tags: ['veg', 'lunch', 'dinner'], emoji: '🍲'),
  FoodItem(name: 'Tofu Stir Fry + Roti (2)', calories: 370, protein: 22, carbs: 36, fat: 14, costPerServing: 35, servingSize: '150g tofu + 2 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🥢'),
  FoodItem(name: 'Moong Dal + Roti (3)', calories: 380, protein: 20, carbs: 60, fat: 5, costPerServing: 18, servingSize: '1 cup dal + 3 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),
  FoodItem(name: 'Palak Dal + Rice', calories: 340, protein: 16, carbs: 56, fat: 5, costPerServing: 20, servingSize: '1 cup dal + 1 cup rice', tags: ['veg', 'lunch', 'dinner'], emoji: '🥬'),
  FoodItem(name: 'Aloo Gobi + Roti (2)', calories: 300, protein: 9, carbs: 50, fat: 7, costPerServing: 18, servingSize: '1 bowl + 2 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🥗'),
  FoodItem(name: 'Dal Khichdi', calories: 330, protein: 14, carbs: 58, fat: 5, costPerServing: 18, servingSize: '1 large bowl', tags: ['veg', 'lunch', 'dinner'], emoji: '🍲'),
  FoodItem(name: 'Paneer Paratha (2) + Curd', calories: 500, protein: 22, carbs: 52, fat: 24, costPerServing: 55, servingSize: '2 parathas + 100g curd', tags: ['veg', 'lunch'], emoji: '🫓'),
  FoodItem(name: 'Chana Dal + Roti (2)', calories: 360, protein: 18, carbs: 58, fat: 5, costPerServing: 16, servingSize: '1 cup + 2 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),

  // ══════════════════════════════════════════════
  //  EGG LUNCH / DINNER
  // ══════════════════════════════════════════════
  FoodItem(name: 'Egg Curry (2 eggs) + Rice', calories: 380, protein: 24, carbs: 48, fat: 14, costPerServing: 38, servingSize: '2 eggs + 1 cup rice', tags: ['egg', 'lunch', 'dinner'], emoji: '🥚'),
  FoodItem(name: 'Omelette (3 eggs) + Roti (2)', calories: 420, protein: 26, carbs: 36, fat: 20, costPerServing: 40, servingSize: '3 eggs + 2 rotis', tags: ['egg', 'lunch', 'dinner'], emoji: '🍳'),
  FoodItem(name: 'Egg Fried Rice', calories: 400, protein: 20, carbs: 52, fat: 12, costPerServing: 35, servingSize: '1 bowl', tags: ['egg', 'lunch', 'dinner'], emoji: '🍳'),
  FoodItem(name: 'Egg Salad Bowl', calories: 260, protein: 22, carbs: 12, fat: 14, costPerServing: 30, servingSize: '3 eggs + salad', tags: ['egg', 'lunch', 'dinner'], emoji: '🥗'),

  // ══════════════════════════════════════════════
  //  NON-VEG LUNCH / DINNER
  // ══════════════════════════════════════════════
  FoodItem(name: 'Chicken Breast + Rice + Salad', calories: 420, protein: 45, carbs: 48, fat: 6, costPerServing: 65, servingSize: '200g chicken + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🍗'),
  FoodItem(name: 'Chicken Curry + Roti (3)', calories: 480, protein: 38, carbs: 48, fat: 14, costPerServing: 70, servingSize: '200g chicken + 3 rotis', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🍛'),
  FoodItem(name: 'Grilled Fish + Rice + Dal', calories: 420, protein: 40, carbs: 46, fat: 8, costPerServing: 65, servingSize: '200g fish + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🐟'),
  FoodItem(name: 'Fish Curry + Steamed Rice', calories: 450, protein: 38, carbs: 52, fat: 10, costPerServing: 75, servingSize: '200g fish + 1.5 cup rice', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🍛'),
  FoodItem(name: 'Mutton Curry + Rice', calories: 520, protein: 36, carbs: 44, fat: 20, costPerServing: 90, servingSize: '150g mutton + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🍖'),
  FoodItem(name: 'Tuna Salad Bowl', calories: 240, protein: 32, carbs: 10, fat: 6, costPerServing: 60, servingSize: '1 can tuna + veggies', tags: ['nonveg', 'lunch'], emoji: '🥗'),
  FoodItem(name: 'Grilled Chicken + Salad', calories: 320, protein: 42, carbs: 12, fat: 10, costPerServing: 70, servingSize: '200g chicken + salad', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🥗'),
  FoodItem(name: 'Chicken Keema + Roti (3)', calories: 460, protein: 36, carbs: 44, fat: 16, costPerServing: 65, servingSize: '150g keema + 3 rotis', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🍛'),
  FoodItem(name: 'Chicken Soup + Roti (2)', calories: 320, protein: 30, carbs: 32, fat: 8, costPerServing: 55, servingSize: '1 bowl soup + 2 rotis', tags: ['nonveg', 'dinner'], emoji: '🍵'),
  FoodItem(name: 'Prawn Masala + Rice', calories: 400, protein: 32, carbs: 44, fat: 12, costPerServing: 80, servingSize: '150g prawns + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🦐'),

  // ══════════════════════════════════════════════
  //  VEG SNACKS
  // ══════════════════════════════════════════════
  FoodItem(name: 'Mixed Nuts (Almonds + Walnuts)', calories: 180, protein: 5, carbs: 6, fat: 16, costPerServing: 28, servingSize: '30g', tags: ['veg', 'snack'], emoji: '🥜'),
  FoodItem(name: 'Sprouts Chaat', calories: 140, protein: 9, carbs: 22, fat: 1, costPerServing: 12, servingSize: '1 cup', tags: ['veg', 'snack'], emoji: '🌱'),
  FoodItem(name: 'Roasted Chana', calories: 130, protein: 8, carbs: 20, fat: 2, costPerServing: 8, servingSize: '40g', tags: ['veg', 'snack'], emoji: '🫘'),
  FoodItem(name: 'Makhana (Roasted Fox Nuts)', calories: 100, protein: 4, carbs: 20, fat: 0.5, costPerServing: 15, servingSize: '30g', tags: ['veg', 'snack'], emoji: '🫘'),
  FoodItem(name: 'Sweet Potato (Boiled)', calories: 140, protein: 3, carbs: 32, fat: 0, costPerServing: 12, servingSize: '150g', tags: ['veg', 'snack'], emoji: '🍠'),
  FoodItem(name: 'Paneer Cubes (Raw)', calories: 140, protein: 9, carbs: 2, fat: 11, costPerServing: 20, servingSize: '50g', tags: ['veg', 'snack'], emoji: '🧀'),
  FoodItem(name: 'Fruit Bowl (Seasonal)', calories: 120, protein: 2, carbs: 28, fat: 0.5, costPerServing: 22, servingSize: '1 bowl', tags: ['veg', 'snack'], emoji: '🍉'),
  FoodItem(name: 'Curd / Dahi', calories: 120, protein: 8, carbs: 12, fat: 3, costPerServing: 12, servingSize: '200g', tags: ['veg', 'snack', 'lunch', 'dinner'], emoji: '🥛'),
  FoodItem(name: 'Peanuts (Boiled)', calories: 160, protein: 7, carbs: 10, fat: 12, costPerServing: 8, servingSize: '40g', tags: ['veg', 'snack'], emoji: '🥜'),
  FoodItem(name: 'Murmura (Puffed Rice) Chaat', calories: 110, protein: 2, carbs: 24, fat: 1, costPerServing: 6, servingSize: '1 cup', tags: ['veg', 'snack'], emoji: '🍚'),

  // ══════════════════════════════════════════════
  //  EGG / NONVEG SNACKS
  // ══════════════════════════════════════════════
  FoodItem(name: 'Boiled Eggs (2)', calories: 140, protein: 12, carbs: 1, fat: 10, costPerServing: 16, servingSize: '2 eggs', tags: ['egg', 'nonveg', 'snack'], emoji: '🥚'),
  FoodItem(name: 'Chicken Tikka (150g)', calories: 210, protein: 30, carbs: 4, fat: 8, costPerServing: 60, servingSize: '150g', tags: ['nonveg', 'snack'], emoji: '🍢'),
  FoodItem(name: 'Tuna on Crackers', calories: 180, protein: 20, carbs: 14, fat: 4, costPerServing: 45, servingSize: '75g tuna + crackers', tags: ['nonveg', 'snack'], emoji: '🐟'),
];
