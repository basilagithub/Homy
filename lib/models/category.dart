import 'package:flutter/material.dart';

class Category {
  final int id;
  final String name;
  final String name_ar;
  final String name_de;
  final String image;

  const Category(
      {required this.id,
      required this.name,
      required this.image,
      required this.name_ar,
      required this.name_de});

  static List<Category> getCategory() {
    return [
      Category(
          id: 1,
          name: 'Fresh vegetables',
          name_ar: 'خضروات',
          name_de: 'Frisches Gemüse',
          image: 'assets/images/category_image/artichoke.png'),
      Category(
          id: 2,
          name: 'Fresh fruits',
          name_ar: 'فواكه',
          name_de: 'Frisches obst',
          image: 'assets/images/category_image/apple.png'),
      Category(
          id: 3,
          name: 'Condiments / Sauces',
          name_ar: 'التوابل / الصلصات',
          name_de: 'Gewürze / Saucen',
          image: 'assets/images/category_image/sauces.png'),
      Category(
          id: 4,
          name: 'Dairy',
          name_ar: 'منتجات الألبان',
          name_de: 'Milchprodukte',
          image: 'assets/images/category_image/milk.png'),
      Category(
          id: 5,
          name: 'Cheese',
          name_ar: 'الجبن',
          name_de: 'Käse',
          image: 'assets/images/category_image/cheese.png'),
      Category(
          id: 6,
          name: 'Meat',
          name_ar: 'اللحوم',
          name_de: 'Fleisch',
          image: 'assets/images/category_image/chicken_leg.png'),
      Category(
          id: 7,
          name: 'Baking',
          name_ar: 'الخبز',
          name_de: 'Back',
          image: 'assets/images/category_image/muffin.png'),
      Category(
          id: 8,
          name: 'Seafood',
          name_ar: 'المأكولات البحرية',
          name_de: 'Meeresfrüchte',
          image: 'assets/images/category_image/fish.png'),
      Category(
          id: 9,
          name: 'Frozen',
          name_ar: 'المجمدة',
          name_de: 'Einfrieren',
          image: 'assets/images/category_image/frozen.png'),
      Category(
          id: 10,
          name: 'Snacks',
          name_ar: 'وجبات خفيفة',
          name_de: 'Snacks',
          image: 'assets/images/category_image/wafer.png'),
      Category(
          id: 11,
          name: 'Baked goods',
          name_ar: 'المخبوزات',
          name_de: 'Backwaren',
          image: 'assets/images/category_image/bread.png'),
      Category(
          id: 12,
          name: 'Refrigerated items',
          name_ar: 'المواد المبردة',
          name_de: 'Gekühlte Artikel',
          image: 'assets/images/category_image/frozen.png'),
      Category(
          id: 13,
          name: 'Canned foods',
          name_ar: 'الأطعمة المعلبة',
          name_de: 'Konserve',
          image: 'assets/images/category_image/peanut_butter.png'),
      Category(
          id: 14,
          name: 'Spices & herbs',
          name_ar: 'التوابل والأعشاب',
          name_de: 'Gewürze & Kräuter',
          image: 'assets/images/category_image/salt_shaker.png'),
      Category(
          id: 15,
          name: 'Themed meals',
          name_ar: 'وجبات',
          name_de: 'Themenmahlzeiten',
          image: 'assets/images/category_image/pizza.png'),
      Category(
          id: 16,
          name: 'Beverages',
          name_ar: 'المشروبات',
          name_de: 'Getränk',
          image: 'assets/images/category_image/cocktail.png'),
      Category(
          id: 17,
          name: 'Various groceries',
          name_ar: 'محلات البقالة المختلفة',
          name_de: 'Verschiedene Lebensmittel',
          image: 'assets/images/category_image/market.png'),
      Category(
          id: 18,
          name: 'Kitchen',
          name_ar: 'المطبخ',
          name_de: 'Küche',
          image: 'assets/images/category_image/toaster.png'),
      Category(
          id: 19,
          name: 'Cleaning products',
          name_ar: 'منتجات التنظيف',
          name_de: 'Reinigungsprodukte',
          image: 'assets/images/category_image/broom.png'),
      Category(
          id: 20,
          name: 'Personal care',
          name_ar: 'العناية الشخصية',
          name_de: 'Körperpflege',
          image: 'assets/images/category_image/bottle_scotch.png'),
      Category(
          id: 21,
          name: 'Baby stuff',
          name_ar: 'اغراض الطفل',
          name_de: 'Babysachen',
          image: 'assets/images/category_image/stroller_carrycot.png'),
      Category(
          id: 22,
          name: 'Pets',
          name_ar: 'الحيوانات الأليفة',
          name_de: 'Haustiere',
          image: 'assets/images/category_image/dog.png'),
      Category(
          id: 23,
          name: 'Office supplies',
          name_ar: 'اللوازم المكتبية',
          name_de: 'Büromaterial',
          image: 'assets/images/category_image/office.png'),
      Category(
          id: 24,
          name: 'Carcinogens',
          name_ar: 'المواد تدخين',
          name_de: 'Karzinogen',
          image: 'assets/images/category_image/market.png'),
      Category(
          id: 25,
          name: 'Other stuff',
          name_ar: 'أشياء أخرى',
          name_de: 'Andere Sachen',
          image: 'assets/images/category_image/material_library.png'),
      Category(
          id: 26,
          name: 'Medicine',
          name_ar: 'ادوية',
          name_de: 'Medizin',
          image: 'assets/images/category_image/pills.png'),
    ];
  }
}
/**1	Fresh vegetables	
2	Fresh fruits	
3	Condiments / Sauces	
4	Dairy	
5	Cheese	
6	Meat	
7	Baking	
8	Seafood	
9	Frozen	
10	Snacks	
11	Kitchen	
12	Baked goods	
13	Refrigerated items	
14	Canned foods	
15	Spices & herbs	
16	Themed meals	
17	Beverages	
18	Cleaning products	
19	Personal care	
20	Various groceries	
21	Baby stuff	
22	Pets	
23	Office supplies	
24	Carcinogens	
25	Other stuff	
26	Medicine	
 */