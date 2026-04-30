class Recipe {
  int RecipeId = 1;
  String RecipeName = '';
  String Description = '';
  int RecipeCategoryId = 1;
  String RecipeItems = '';

  // Recipe({required this.RecipeId, required this.RecipeName});
  Recipe(dynamic obj) {
    RecipeId = obj['Recipe_id'];
    RecipeName = obj['Recipe_name'];
    Description = obj['Description'];
    RecipeCategoryId = obj['category_id'];
    RecipeItems = obj['recipe_items'];
  }
  Recipe.fromMap(Map<String, dynamic> data) {
    RecipeId = data['recipe_id'];
    RecipeName = data['recipe_name'];
    RecipeCategoryId = data['recipe_category_id'];
    Description = data['recipe_desc'];
    RecipeItems = data['recipe_items'];
  }
  Map<String, dynamic> toMap() => {
        'recipe_id': RecipeId,
        'recipe_name': RecipeName,
        'recipe_category_id': RecipeCategoryId,
        'recipe_desc': Description,
        'recipe_items': RecipeItems
      };

  int get Recipe_id => RecipeId;
  String get Recipe_name => RecipeName;
  int get category_id => RecipeCategoryId;
  String get Description_ => Description;
  String get _Recipe_items => RecipeItems;
}
