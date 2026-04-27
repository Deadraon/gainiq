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
//  INDIAN FOOD DATABASE  (150+ items)
//  Diet tags : 'veg', 'egg', 'nonveg'
//  Meal tags : 'breakfast', 'lunch', 'dinner', 'snack'
//  Goal tags : 'bulking', 'cutting', 'weight_loss', 'lean_muscle', 'maintenance'
//  Budget    : items range ₹6–₹120 per serving
// ─────────────────────────────────────────────────────────────
const List<FoodItem> indianFoodDB = [

  // ══════════════════════════════════════════════
  //  VEG BREAKFAST — HIGH PROTEIN
  // ══════════════════════════════════════════════
  FoodItem(name: 'Moong Dal Chilla (3)', calories: 280, protein: 20, carbs: 32, fat: 5, costPerServing: 16, servingSize: '3 chillas with green chutney', tags: ['veg', 'breakfast', 'snack', 'cutting', 'lean_muscle'], emoji: '🥞'),
  FoodItem(name: 'Besan Chilla with Paneer Stuffing', calories: 340, protein: 22, carbs: 32, fat: 12, costPerServing: 30, servingSize: '2 stuffed chillas', tags: ['veg', 'breakfast', 'lean_muscle', 'bulking'], emoji: '🥞'),
  FoodItem(name: 'Greek Yogurt Parfait with Nuts', calories: 280, protein: 20, carbs: 22, fat: 10, costPerServing: 50, servingSize: '200g yogurt + 20g nuts + berries', tags: ['veg', 'breakfast', 'snack', 'cutting', 'lean_muscle'], emoji: '🥛'),
  FoodItem(name: 'Paneer Bhurji + Multigrain Roti (2)', calories: 420, protein: 28, carbs: 38, fat: 18, costPerServing: 55, servingSize: '100g paneer bhurji + 2 rotis', tags: ['veg', 'breakfast', 'lunch', 'bulking', 'lean_muscle'], emoji: '🧀'),
  FoodItem(name: 'Soya Milk Oats Porridge', calories: 300, protein: 16, carbs: 44, fat: 6, costPerServing: 28, servingSize: '60g oats + 250ml soya milk', tags: ['veg', 'breakfast', 'lean_muscle', 'maintenance'], emoji: '🥣'),
  FoodItem(name: 'Pesarattu (Green Moong Dosa 3)', calories: 280, protein: 18, carbs: 38, fat: 5, costPerServing: 18, servingSize: '3 dosas + ginger chutney', tags: ['veg', 'breakfast', 'cutting', 'lean_muscle'], emoji: '🥞'),
  FoodItem(name: 'Quinoa Veggie Upma', calories: 300, protein: 12, carbs: 48, fat: 7, costPerServing: 42, servingSize: '1 bowl with veggies', tags: ['veg', 'breakfast', 'lunch', 'maintenance', 'lean_muscle'], emoji: '🥗'),
  FoodItem(name: 'Poha with Peanuts & Sprouts', calories: 300, protein: 11, carbs: 48, fat: 7, costPerServing: 16, servingSize: '1.5 cups', tags: ['veg', 'breakfast', 'maintenance'], emoji: '🍚'),
  FoodItem(name: 'Oats with Milk & Banana', calories: 340, protein: 14, carbs: 56, fat: 7, costPerServing: 24, servingSize: '60g oats + 200ml milk + 1 banana', tags: ['veg', 'breakfast', 'bulking', 'maintenance'], emoji: '🥣'),
  FoodItem(name: 'Muesli + Milk + Honey', calories: 360, protein: 12, carbs: 60, fat: 8, costPerServing: 36, servingSize: '50g muesli + 200ml milk', tags: ['veg', 'breakfast', 'maintenance', 'bulking'], emoji: '🥣'),
  FoodItem(name: 'Dalia Porridge with Jaggery', calories: 260, protein: 9, carbs: 50, fat: 3, costPerServing: 12, servingSize: '1 bowl', tags: ['veg', 'breakfast', 'weight_loss', 'cutting'], emoji: '🥣'),
  FoodItem(name: 'Idli (4) + Sambar + Coconut Chutney', calories: 320, protein: 12, carbs: 60, fat: 4, costPerServing: 22, servingSize: '4 idlis + sambar', tags: ['veg', 'breakfast', 'lunch', 'maintenance', 'weight_loss'], emoji: '🍚'),
  FoodItem(name: 'Upma with Mixed Veggies', calories: 260, protein: 8, carbs: 44, fat: 7, costPerServing: 15, servingSize: '1 cup', tags: ['veg', 'breakfast', 'weight_loss', 'maintenance'], emoji: '🫕'),
  FoodItem(name: 'Methi Thepla (2) + Curd', calories: 320, protein: 10, carbs: 44, fat: 10, costPerServing: 22, servingSize: '2 theplas + 100g curd', tags: ['veg', 'breakfast', 'lunch', 'maintenance'], emoji: '🫓'),
  FoodItem(name: 'Peanut Butter Banana Toast', calories: 360, protein: 14, carbs: 46, fat: 14, costPerServing: 32, servingSize: '2 whole-wheat slices + 2 tbsp PB + banana', tags: ['veg', 'breakfast', 'bulking', 'lean_muscle'], emoji: '🍞'),
  FoodItem(name: 'Sattu Porridge with Jaggery', calories: 220, protein: 12, carbs: 36, fat: 3, costPerServing: 12, servingSize: '50g sattu + water + jaggery', tags: ['veg', 'breakfast', 'snack', 'cutting', 'weight_loss'], emoji: '🥤'),
  FoodItem(name: 'Ragi Mudde + Sambar', calories: 280, protein: 8, carbs: 58, fat: 2, costPerServing: 18, servingSize: '2 mudde + 1 bowl sambar', tags: ['veg', 'breakfast', 'lunch', 'weight_loss', 'maintenance'], emoji: '🍲'),
  FoodItem(name: 'Paneer Paratha (2) + Curd', calories: 520, protein: 24, carbs: 54, fat: 24, costPerServing: 58, servingSize: '2 parathas + 100g curd', tags: ['veg', 'breakfast', 'lunch', 'bulking'], emoji: '🫓'),
  FoodItem(name: 'Tofu Scramble + Whole Wheat Toast', calories: 320, protein: 22, carbs: 28, fat: 12, costPerServing: 40, servingSize: '150g tofu + 2 slices', tags: ['veg', 'breakfast', 'cutting', 'lean_muscle'], emoji: '🍳'),
  FoodItem(name: 'Curd Rice with Pomegranate', calories: 240, protein: 8, carbs: 42, fat: 4, costPerServing: 20, servingSize: '1 bowl', tags: ['veg', 'breakfast', 'lunch', 'weight_loss'], emoji: '🍚'),

  // ══════════════════════════════════════════════
  //  EGG BREAKFAST
  // ══════════════════════════════════════════════
  FoodItem(name: 'Boiled Eggs (3) + Whole Wheat Toast', calories: 320, protein: 22, carbs: 24, fat: 14, costPerServing: 34, servingSize: '3 eggs + 2 slices', tags: ['egg', 'breakfast', 'lean_muscle', 'cutting'], emoji: '🥚'),
  FoodItem(name: 'Egg White Omelette (5 whites) + Veggies', calories: 120, protein: 20, carbs: 4, fat: 1, costPerServing: 18, servingSize: '5 whites + capsicum + onion', tags: ['egg', 'breakfast', 'cutting', 'weight_loss'], emoji: '🍳'),
  FoodItem(name: 'Whole Egg Omelette (3) + Roti (2)', calories: 440, protein: 26, carbs: 36, fat: 20, costPerServing: 42, servingSize: '3 eggs + 2 rotis', tags: ['egg', 'breakfast', 'bulking', 'lean_muscle'], emoji: '🍳'),
  FoodItem(name: 'Egg Bhurji (3) + Multigrain Roti (2)', calories: 420, protein: 26, carbs: 38, fat: 18, costPerServing: 40, servingSize: '3 eggs spiced + 2 rotis', tags: ['egg', 'breakfast', 'dinner', 'lean_muscle', 'maintenance'], emoji: '🍳'),
  FoodItem(name: 'Scrambled Eggs (2) + Avocado Toast', calories: 380, protein: 18, carbs: 28, fat: 22, costPerServing: 60, servingSize: '2 eggs + 1/2 avocado + 2 slices', tags: ['egg', 'breakfast', 'lean_muscle', 'cutting'], emoji: '🥑'),
  FoodItem(name: 'Boiled Eggs (2) + Banana + Peanut Butter', calories: 360, protein: 20, carbs: 38, fat: 14, costPerServing: 32, servingSize: '2 eggs + 1 banana + 1 tbsp PB', tags: ['egg', 'breakfast', 'snack', 'bulking', 'lean_muscle'], emoji: '🥚'),
  FoodItem(name: 'Egg Poha (2 eggs)', calories: 340, protein: 18, carbs: 44, fat: 10, costPerServing: 28, servingSize: '1 cup poha + 2 eggs', tags: ['egg', 'breakfast', 'maintenance', 'lean_muscle'], emoji: '🍳'),
  FoodItem(name: 'Masala Omelette (2) + Brown Bread', calories: 300, protein: 18, carbs: 26, fat: 14, costPerServing: 32, servingSize: '2 eggs + 2 slices brown bread', tags: ['egg', 'breakfast', 'maintenance', 'lean_muscle'], emoji: '🍳'),

  // ══════════════════════════════════════════════
  //  NON-VEG BREAKFAST
  // ══════════════════════════════════════════════
  FoodItem(name: 'Chicken Keema Paratha (2)', calories: 460, protein: 30, carbs: 46, fat: 16, costPerServing: 58, servingSize: '2 stuffed parathas', tags: ['nonveg', 'breakfast', 'lunch', 'bulking'], emoji: '🫓'),
  FoodItem(name: 'Tuna Whole Wheat Sandwich', calories: 340, protein: 28, carbs: 36, fat: 8, costPerServing: 52, servingSize: '2 slices + 80g tuna + veggies', tags: ['nonveg', 'breakfast', 'lunch', 'cutting', 'lean_muscle'], emoji: '🥪'),
  FoodItem(name: 'Chicken Oats Porridge', calories: 380, protein: 32, carbs: 42, fat: 8, costPerServing: 55, servingSize: '60g oats + 100g minced chicken', tags: ['nonveg', 'breakfast', 'lean_muscle', 'bulking'], emoji: '🥣'),
  FoodItem(name: 'Boiled Chicken + Brown Rice Bowl', calories: 420, protein: 40, carbs: 44, fat: 8, costPerServing: 65, servingSize: '150g chicken + 1 cup rice', tags: ['nonveg', 'breakfast', 'lunch', 'lean_muscle', 'cutting'], emoji: '🍗'),

  // ══════════════════════════════════════════════
  //  UNIVERSAL BREAKFAST ADDITIONS
  // ══════════════════════════════════════════════
  FoodItem(name: 'Whey Protein Shake', calories: 140, protein: 26, carbs: 5, fat: 2, costPerServing: 68, servingSize: '1 scoop + 300ml water/milk', tags: ['veg', 'egg', 'nonveg', 'breakfast', 'snack', 'bulking', 'lean_muscle', 'cutting'], emoji: '🥤'),
  FoodItem(name: 'Banana + Peanut Butter', calories: 250, protein: 7, carbs: 38, fat: 9, costPerServing: 22, servingSize: '1 banana + 1.5 tbsp PB', tags: ['veg', 'egg', 'nonveg', 'snack', 'breakfast', 'bulking'], emoji: '🍌'),
  FoodItem(name: 'Mixed Dry Fruits & Nuts', calories: 200, protein: 5, carbs: 16, fat: 14, costPerServing: 35, servingSize: '35g mixed (almonds, cashews, raisins)', tags: ['veg', 'egg', 'nonveg', 'snack', 'breakfast'], emoji: '🥜'),

  // ══════════════════════════════════════════════
  //  VEG LUNCH — GOAL SPECIFIC
  // ══════════════════════════════════════════════

  // High protein veg lunch
  FoodItem(name: 'Paneer Tikka + Brown Rice', calories: 480, protein: 30, carbs: 52, fat: 18, costPerServing: 68, servingSize: '150g paneer + 1 cup rice', tags: ['veg', 'lunch', 'dinner', 'bulking', 'lean_muscle'], emoji: '🧀'),
  FoodItem(name: 'Soya Chunks Masala + Roti (3)', calories: 420, protein: 34, carbs: 52, fat: 6, costPerServing: 26, servingSize: '60g dry soya + 3 rotis', tags: ['veg', 'lunch', 'dinner', 'bulking', 'lean_muscle', 'cutting'], emoji: '🫘'),
  FoodItem(name: 'Rajma Masala + Brown Rice', calories: 420, protein: 22, carbs: 70, fat: 5, costPerServing: 26, servingSize: '1 cup rajma + 1 cup brown rice', tags: ['veg', 'lunch', 'dinner', 'bulking', 'maintenance'], emoji: '🫘'),
  FoodItem(name: 'Chole Masala + Bhatura (2)', calories: 580, protein: 18, carbs: 88, fat: 18, costPerServing: 35, servingSize: '1 cup chole + 2 bhaturas', tags: ['veg', 'lunch', 'bulking'], emoji: '🫘'),
  FoodItem(name: 'Palak Paneer + Roti (3)', calories: 460, protein: 24, carbs: 44, fat: 22, costPerServing: 60, servingSize: '150g + 3 rotis', tags: ['veg', 'lunch', 'dinner', 'lean_muscle', 'maintenance'], emoji: '🥬'),
  FoodItem(name: 'Paneer Sabzi + Roti (3)', calories: 500, protein: 28, carbs: 48, fat: 24, costPerServing: 65, servingSize: '150g paneer + 3 rotis', tags: ['veg', 'lunch', 'dinner', 'bulking', 'lean_muscle'], emoji: '🧀'),
  FoodItem(name: 'Dal Makhani + Roti (2)', calories: 420, protein: 18, carbs: 58, fat: 14, costPerServing: 30, servingSize: '1 bowl dal + 2 rotis', tags: ['veg', 'lunch', 'dinner', 'bulking', 'maintenance'], emoji: '🫘'),
  FoodItem(name: 'Tofu Stir Fry + Brown Rice', calories: 380, protein: 24, carbs: 44, fat: 12, costPerServing: 38, servingSize: '150g tofu + 1 cup brown rice', tags: ['veg', 'lunch', 'dinner', 'lean_muscle', 'cutting'], emoji: '🥢'),

  // Moderate veg lunch
  FoodItem(name: 'Dal + Rice + Sabzi + Salad', calories: 420, protein: 18, carbs: 72, fat: 7, costPerServing: 28, servingSize: '1 cup dal + rice + sabzi', tags: ['veg', 'lunch', 'dinner', 'maintenance'], emoji: '🫘'),
  FoodItem(name: 'Moong Dal + Roti (3)', calories: 380, protein: 20, carbs: 62, fat: 5, costPerServing: 20, servingSize: '1 cup dal + 3 rotis', tags: ['veg', 'lunch', 'dinner', 'maintenance', 'weight_loss'], emoji: '🫘'),
  FoodItem(name: 'Chana Dal + Brown Rice', calories: 380, protein: 20, carbs: 64, fat: 5, costPerServing: 20, servingSize: '1 cup dal + 1 cup rice', tags: ['veg', 'lunch', 'dinner', 'maintenance', 'lean_muscle'], emoji: '🫘'),
  FoodItem(name: 'Mixed Veg Khichdi + Curd', calories: 380, protein: 14, carbs: 62, fat: 8, costPerServing: 22, servingSize: '1 large bowl + 100g curd', tags: ['veg', 'lunch', 'dinner', 'maintenance', 'weight_loss'], emoji: '🍲'),
  FoodItem(name: 'Baingan Bharta + Roti (3)', calories: 320, protein: 10, carbs: 52, fat: 8, costPerServing: 22, servingSize: '1 bowl + 3 rotis', tags: ['veg', 'lunch', 'dinner', 'weight_loss', 'maintenance'], emoji: '🫙'),
  FoodItem(name: 'Palak Dal + Brown Rice', calories: 360, protein: 18, carbs: 60, fat: 5, costPerServing: 22, servingSize: '1 cup dal + 1 cup rice', tags: ['veg', 'lunch', 'dinner', 'cutting', 'maintenance'], emoji: '🥬'),

  // Low cal veg lunch
  FoodItem(name: 'Sprouts Salad Bowl', calories: 200, protein: 14, carbs: 28, fat: 3, costPerServing: 18, servingSize: '1.5 cups mixed sprouts + lemon', tags: ['veg', 'lunch', 'snack', 'cutting', 'weight_loss'], emoji: '🌱'),
  FoodItem(name: 'Vegetable Soup + 2 Rotis', calories: 260, protein: 9, carbs: 44, fat: 5, costPerServing: 18, servingSize: '1 bowl soup + 2 rotis', tags: ['veg', 'lunch', 'dinner', 'weight_loss', 'cutting'], emoji: '🍵'),
  FoodItem(name: 'Methi Sabzi + Jowar Roti (2)', calories: 280, protein: 10, carbs: 46, fat: 6, costPerServing: 18, servingSize: '1 bowl + 2 rotis', tags: ['veg', 'lunch', 'dinner', 'weight_loss'], emoji: '🥬'),
  FoodItem(name: 'Lauki Dal + Roti (2)', calories: 300, protein: 14, carbs: 50, fat: 5, costPerServing: 18, servingSize: '1 bowl + 2 rotis', tags: ['veg', 'lunch', 'dinner', 'weight_loss', 'cutting'], emoji: '🫘'),
  FoodItem(name: 'Quinoa Pulao with Veggies', calories: 340, protein: 12, carbs: 58, fat: 7, costPerServing: 45, servingSize: '1 bowl', tags: ['veg', 'lunch', 'dinner', 'lean_muscle', 'maintenance'], emoji: '🥗'),
  FoodItem(name: 'Millet Khichdi (Bajra/Jowar)', calories: 320, protein: 12, carbs: 58, fat: 5, costPerServing: 16, servingSize: '1 large bowl', tags: ['veg', 'lunch', 'dinner', 'weight_loss', 'cutting'], emoji: '🍲'),

  // ══════════════════════════════════════════════
  //  EGG LUNCH / DINNER
  // ══════════════════════════════════════════════
  FoodItem(name: 'Egg Curry (3 eggs) + Rice', calories: 440, protein: 28, carbs: 50, fat: 16, costPerServing: 44, servingSize: '3 eggs + 1 cup rice', tags: ['egg', 'lunch', 'dinner', 'lean_muscle', 'maintenance'], emoji: '🥚'),
  FoodItem(name: 'Omelette (3 eggs) + Roti (3)', calories: 460, protein: 28, carbs: 46, fat: 20, costPerServing: 44, servingSize: '3 eggs + 3 rotis', tags: ['egg', 'lunch', 'dinner', 'bulking', 'lean_muscle'], emoji: '🍳'),
  FoodItem(name: 'Egg Fried Rice (3 eggs)', calories: 440, protein: 22, carbs: 58, fat: 14, costPerServing: 38, servingSize: '1 bowl', tags: ['egg', 'lunch', 'dinner', 'bulking', 'maintenance'], emoji: '🍳'),
  FoodItem(name: 'Egg Salad Bowl (3 eggs)', calories: 280, protein: 24, carbs: 12, fat: 16, costPerServing: 32, servingSize: '3 eggs + cucumber + tomato + greens', tags: ['egg', 'lunch', 'dinner', 'cutting', 'weight_loss'], emoji: '🥗'),
  FoodItem(name: 'Egg Dal (2 eggs) + Roti (2)', calories: 420, protein: 28, carbs: 50, fat: 14, costPerServing: 36, servingSize: 'Egg-dal mix + 2 rotis', tags: ['egg', 'lunch', 'dinner', 'lean_muscle', 'maintenance'], emoji: '🥚'),
  FoodItem(name: 'Boiled Egg Rice Bowl (4 eggs)', calories: 500, protein: 32, carbs: 56, fat: 16, costPerServing: 45, servingSize: '4 eggs + 1.5 cup rice + salad', tags: ['egg', 'lunch', 'dinner', 'bulking', 'lean_muscle'], emoji: '🥚'),

  // ══════════════════════════════════════════════
  //  NON-VEG LUNCH / DINNER
  // ══════════════════════════════════════════════

  // Chicken
  FoodItem(name: 'Grilled Chicken Breast + Brown Rice', calories: 440, protein: 48, carbs: 46, fat: 7, costPerServing: 70, servingSize: '200g chicken + 1 cup brown rice', tags: ['nonveg', 'lunch', 'dinner', 'lean_muscle', 'cutting', 'bulking'], emoji: '🍗'),
  FoodItem(name: 'Chicken Curry + Roti (3)', calories: 500, protein: 40, carbs: 50, fat: 14, costPerServing: 72, servingSize: '200g chicken + 3 rotis', tags: ['nonveg', 'lunch', 'dinner', 'bulking', 'lean_muscle'], emoji: '🍛'),
  FoodItem(name: 'Grilled Chicken Salad', calories: 320, protein: 44, carbs: 12, fat: 10, costPerServing: 68, servingSize: '200g chicken + mixed greens', tags: ['nonveg', 'lunch', 'dinner', 'cutting', 'weight_loss', 'lean_muscle'], emoji: '🥗'),
  FoodItem(name: 'Chicken Keema + Roti (3)', calories: 480, protein: 38, carbs: 46, fat: 16, costPerServing: 68, servingSize: '150g keema + 3 rotis', tags: ['nonveg', 'lunch', 'dinner', 'bulking', 'lean_muscle'], emoji: '🍛'),
  FoodItem(name: 'Chicken Tikka + Brown Rice', calories: 460, protein: 46, carbs: 44, fat: 10, costPerServing: 75, servingSize: '200g chicken tikka + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner', 'lean_muscle', 'cutting'], emoji: '🍢'),
  FoodItem(name: 'Chicken Soup + Roti (2)', calories: 340, protein: 32, carbs: 34, fat: 8, costPerServing: 58, servingSize: '1 bowl clear soup + 200g chicken + 2 rotis', tags: ['nonveg', 'dinner', 'cutting', 'weight_loss'], emoji: '🍵'),
  FoodItem(name: 'Chicken Pulao', calories: 520, protein: 36, carbs: 60, fat: 14, costPerServing: 78, servingSize: '1 large bowl', tags: ['nonveg', 'lunch', 'dinner', 'bulking', 'maintenance'], emoji: '🍛'),
  FoodItem(name: 'Tandoori Chicken + Dal + Rice', calories: 560, protein: 50, carbs: 54, fat: 14, costPerServing: 90, servingSize: '250g chicken + dal + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner', 'bulking', 'lean_muscle'], emoji: '🍗'),

  // Fish
  FoodItem(name: 'Grilled Fish + Brown Rice + Dal', calories: 440, protein: 42, carbs: 48, fat: 8, costPerServing: 68, servingSize: '200g fish + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner', 'lean_muscle', 'cutting', 'maintenance'], emoji: '🐟'),
  FoodItem(name: 'Fish Curry + Steamed Rice', calories: 460, protein: 40, carbs: 52, fat: 10, costPerServing: 78, servingSize: '200g fish curry + 1.5 cup rice', tags: ['nonveg', 'lunch', 'dinner', 'maintenance', 'lean_muscle'], emoji: '🍛'),
  FoodItem(name: 'Baked Fish + Veggies + Roti (2)', calories: 380, protein: 38, carbs: 34, fat: 10, costPerServing: 72, servingSize: '200g fish + roasted veggies + 2 rotis', tags: ['nonveg', 'lunch', 'dinner', 'cutting', 'lean_muscle'], emoji: '🐟'),
  FoodItem(name: 'Tuna Salad Bowl', calories: 260, protein: 34, carbs: 10, fat: 6, costPerServing: 62, servingSize: '1 can tuna + cucumber + tomato + olive oil', tags: ['nonveg', 'lunch', 'cutting', 'weight_loss'], emoji: '🥗'),

  // Mutton / Prawn
  FoodItem(name: 'Mutton Curry + Rice', calories: 540, protein: 38, carbs: 46, fat: 22, costPerServing: 95, servingSize: '150g mutton + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner', 'bulking'], emoji: '🍖'),
  FoodItem(name: 'Prawn Masala + Brown Rice', calories: 420, protein: 34, carbs: 46, fat: 12, costPerServing: 85, servingSize: '150g prawns + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner', 'lean_muscle', 'maintenance'], emoji: '🦐'),
  FoodItem(name: 'Prawn Stir Fry + Roti (2)', calories: 360, protein: 32, carbs: 32, fat: 10, costPerServing: 82, servingSize: '150g prawns + 2 rotis', tags: ['nonveg', 'lunch', 'dinner', 'lean_muscle', 'cutting'], emoji: '🦐'),

  // ══════════════════════════════════════════════
  //  VEG DINNER (lighter options)
  // ══════════════════════════════════════════════
  FoodItem(name: 'Moong Dal Soup + Roti (2)', calories: 300, protein: 16, carbs: 50, fat: 4, costPerServing: 18, servingSize: '1 bowl soup + 2 rotis', tags: ['veg', 'dinner', 'weight_loss', 'cutting'], emoji: '🍵'),
  FoodItem(name: 'Vegetable Daliya + Curd', calories: 300, protein: 10, carbs: 52, fat: 5, costPerServing: 16, servingSize: '1 bowl daliya + 100g curd', tags: ['veg', 'dinner', 'weight_loss', 'maintenance'], emoji: '🥣'),
  FoodItem(name: 'Paneer Salad + 1 Roti', calories: 280, protein: 18, carbs: 22, fat: 14, costPerServing: 40, servingSize: '100g paneer cubes + salad + 1 roti', tags: ['veg', 'dinner', 'cutting', 'lean_muscle'], emoji: '🥗'),
  FoodItem(name: 'Toor Dal + Roti (2) + Salad', calories: 340, protein: 16, carbs: 56, fat: 5, costPerServing: 18, servingSize: '1 cup toor dal + 2 rotis', tags: ['veg', 'dinner', 'maintenance', 'weight_loss'], emoji: '🫘'),
  FoodItem(name: 'Mushroom Masala + Roti (2)', calories: 300, protein: 12, carbs: 40, fat: 10, costPerServing: 30, servingSize: '200g mushrooms + 2 rotis', tags: ['veg', 'dinner', 'cutting', 'lean_muscle', 'maintenance'], emoji: '🍄'),

  // ══════════════════════════════════════════════
  //  VEG SNACKS — GOAL SPECIFIC
  // ══════════════════════════════════════════════
  FoodItem(name: 'Roasted Chana', calories: 130, protein: 9, carbs: 20, fat: 2, costPerServing: 8, servingSize: '40g', tags: ['veg', 'snack', 'cutting', 'weight_loss', 'maintenance'], emoji: '🫘'),
  FoodItem(name: 'Makhana (Fox Nuts) Roasted', calories: 100, protein: 4, carbs: 20, fat: 0.5, costPerServing: 15, servingSize: '30g', tags: ['veg', 'snack', 'cutting', 'weight_loss'], emoji: '🫘'),
  FoodItem(name: 'Mixed Nuts (30g)', calories: 180, protein: 5, carbs: 6, fat: 16, costPerServing: 28, servingSize: '30g almonds + walnuts', tags: ['veg', 'snack', 'lean_muscle', 'maintenance'], emoji: '🥜'),
  FoodItem(name: 'Sprouts Chaat', calories: 150, protein: 10, carbs: 22, fat: 2, costPerServing: 12, servingSize: '1 cup mixed sprouts + lemon + spices', tags: ['veg', 'snack', 'cutting', 'weight_loss', 'lean_muscle'], emoji: '🌱'),
  FoodItem(name: 'Sweet Potato Chaat', calories: 160, protein: 3, carbs: 36, fat: 1, costPerServing: 14, servingSize: '200g boiled sweet potato + spices', tags: ['veg', 'snack', 'bulking', 'maintenance'], emoji: '🍠'),
  FoodItem(name: 'Paneer Cubes + Cucumber', calories: 160, protein: 10, carbs: 4, fat: 12, costPerServing: 22, servingSize: '60g paneer + 1 cucumber', tags: ['veg', 'snack', 'cutting', 'lean_muscle'], emoji: '🧀'),
  FoodItem(name: 'Fruit Bowl (Seasonal)', calories: 120, protein: 2, carbs: 28, fat: 0.5, costPerServing: 22, servingSize: '1 bowl mixed seasonal fruit', tags: ['veg', 'snack', 'weight_loss', 'maintenance'], emoji: '🍉'),
  FoodItem(name: 'Curd (Plain) + Jeera', calories: 120, protein: 8, carbs: 12, fat: 3, costPerServing: 12, servingSize: '200g curd', tags: ['veg', 'snack', 'lunch', 'dinner', 'cutting', 'maintenance'], emoji: '🥛'),
  FoodItem(name: 'Peanuts Boiled', calories: 170, protein: 8, carbs: 10, fat: 13, costPerServing: 8, servingSize: '40g boiled peanuts + salt', tags: ['veg', 'snack', 'bulking', 'lean_muscle'], emoji: '🥜'),
  FoodItem(name: 'Sattu Drink (Salted)', calories: 180, protein: 10, carbs: 30, fat: 2, costPerServing: 10, servingSize: '40g sattu + water + lemon + cumin', tags: ['veg', 'snack', 'breakfast', 'cutting', 'weight_loss'], emoji: '🥤'),
  FoodItem(name: 'Murmura Chaat (Low Oil)', calories: 110, protein: 2, carbs: 24, fat: 1, costPerServing: 6, servingSize: '1 cup + onion + tomato + lemon', tags: ['veg', 'snack', 'weight_loss'], emoji: '🍚'),
  FoodItem(name: 'Coconut Water', calories: 45, protein: 0.5, carbs: 10, fat: 0, costPerServing: 20, servingSize: '1 coconut (300ml)', tags: ['veg', 'egg', 'nonveg', 'snack', 'cutting', 'weight_loss'], emoji: '🥥'),
  FoodItem(name: 'Rajgira (Amaranth) Chikki', calories: 160, protein: 4, carbs: 28, fat: 4, costPerServing: 12, servingSize: '1 bar (35g)', tags: ['veg', 'snack', 'bulking', 'maintenance'], emoji: '🍫'),
  FoodItem(name: 'Oats Energy Balls (3)', calories: 220, protein: 7, carbs: 30, fat: 8, costPerServing: 22, servingSize: '3 balls (oats+PB+jaggery)', tags: ['veg', 'snack', 'bulking', 'lean_muscle'], emoji: '⚽'),
  FoodItem(name: 'Cucumber + Hummus', calories: 130, protein: 5, carbs: 16, fat: 5, costPerServing: 25, servingSize: '1 cucumber + 2 tbsp hummus', tags: ['veg', 'snack', 'cutting', 'weight_loss'], emoji: '🥒'),

  // ══════════════════════════════════════════════
  //  EGG / NON-VEG SNACKS
  // ══════════════════════════════════════════════
  FoodItem(name: 'Boiled Eggs (2)', calories: 140, protein: 12, carbs: 1, fat: 10, costPerServing: 16, servingSize: '2 whole eggs', tags: ['egg', 'nonveg', 'snack', 'cutting', 'lean_muscle', 'maintenance'], emoji: '🥚'),
  FoodItem(name: 'Boiled Eggs (3)', calories: 210, protein: 18, carbs: 1.5, fat: 15, costPerServing: 24, servingSize: '3 whole eggs', tags: ['egg', 'nonveg', 'snack', 'bulking', 'lean_muscle'], emoji: '🥚'),
  FoodItem(name: 'Egg White (5) + Cucumber', calories: 90, protein: 18, carbs: 3, fat: 0.3, costPerServing: 18, servingSize: '5 egg whites + 1 cucumber', tags: ['egg', 'snack', 'cutting', 'weight_loss'], emoji: '🥚'),
  FoodItem(name: 'Chicken Tikka (150g)', calories: 220, protein: 32, carbs: 4, fat: 8, costPerServing: 62, servingSize: '150g grilled chicken tikka', tags: ['nonveg', 'snack', 'lean_muscle', 'cutting'], emoji: '🍢'),
  FoodItem(name: 'Tuna on Whole Wheat Crackers', calories: 190, protein: 22, carbs: 14, fat: 4, costPerServing: 48, servingSize: '80g tuna + 4 crackers', tags: ['nonveg', 'snack', 'cutting', 'lean_muscle'], emoji: '🐟'),
  FoodItem(name: 'Grilled Chicken Strips', calories: 180, protein: 34, carbs: 2, fat: 4, costPerServing: 58, servingSize: '150g lean chicken strips', tags: ['nonveg', 'snack', 'cutting', 'lean_muscle', 'weight_loss'], emoji: '🍗'),

  // ══════════════════════════════════════════════
  //  PROTEIN SUPPLEMENTS (all diets)
  // ══════════════════════════════════════════════
  FoodItem(name: 'Whey + Banana Smoothie', calories: 300, protein: 28, carbs: 38, fat: 3, costPerServing: 75, servingSize: '1 scoop whey + 1 banana + 200ml milk', tags: ['veg', 'egg', 'nonveg', 'snack', 'breakfast', 'bulking', 'lean_muscle'], emoji: '🥤'),
  FoodItem(name: 'Casein Protein + Milk (Night)', calories: 200, protein: 28, carbs: 10, fat: 3, costPerServing: 75, servingSize: '1 scoop casein + 200ml milk', tags: ['veg', 'egg', 'nonveg', 'snack', 'dinner', 'bulking', 'lean_muscle'], emoji: '🥛'),

];