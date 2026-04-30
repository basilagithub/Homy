class RecipeCategory {
  final int id;
  final String name;
  final String name_ar;
  final String name_de;
  final String image;

  const RecipeCategory(
      {required this.id,
      required this.name,
      required this.image,
      required this.name_ar,
      required this.name_de});
  static List<RecipeCategory> getRecipeCategory() {
    return [
      RecipeCategory(
          id: 1,
          name: 'MAIN DISHES',
          name_ar: 'اطباق رئيسية',
          name_de: 'HAUPTGERICHTE',
          image: ''),
      RecipeCategory(
          id: 2,
          name: 'APPETIZERS, SALADS & SIDE DISHES',
          name_ar: 'مقبلات اطباق جانبية مقبلات',
          name_de: 'VORSPEISEN, SALATE & BEILAGEN',
          image: ''),
      RecipeCategory(
          id: 3,
          name: 'MEAT DISHES',
          name_ar: 'اطباق لحوم',
          name_de: 'FLEISCHGERICHTE',
          image: ''),
      RecipeCategory(
          id: 4,
          name: 'FISH DISHES',
          name_ar: 'اطباق اسماك',
          name_de: 'FISCHGERICHTE',
          image: ''),
      RecipeCategory(
          id: 5,
          name: 'VEGAN & VEGETARIAN',
          name_ar: 'نباتي',
          name_de: 'VEGAN & VEGETARISCH',
          image: ''),
      RecipeCategory(
          id: 6,
          name: 'COCKTAILS, LONG DRINKS  DRINKS',
          name_ar: 'كوكتيلات مشروبات',
          name_de: 'COCKTAILS,LONGDRINKS  GETRÄNKE',
          image: ''),
      RecipeCategory(
          id: 7,
          name: 'PASTRIES & DESSERTS',
          name_ar: 'حلويات معجنات',
          name_de: 'GEBÄCK & DESSERT',
          image: ''),
      RecipeCategory(
          id: 8,
          name: 'PREPARED QUICKLY AND EASILY',
          name_ar: 'وجبات سريعة',
          name_de: 'SCHNELL & EINFACH ZUBEREITET',
          image: ''),
    ];
  }
}
