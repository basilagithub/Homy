import 'package:flutter/material.dart';
import 'package:home_order_app/database_helper.dart';
import 'package:home_order_app/models/recipe.dart';
import 'package:home_order_app/models/recipe_category.dart';
import 'package:home_order_app/screens/add_recipe_screen.dart';
import 'package:home_order_app/screens/view_recipe_screen.dart';

class recipe_widget extends StatefulWidget {
  Locale? _locale;
  recipe_widget(Locale? this._locale);

  @override
  State<recipe_widget> createState() => _recipe_widgetState();
}

class _recipe_widgetState extends State<recipe_widget> {
  var recipeList = [];
  var allrecipe = [];
  late DataBaseHelper helper;
  List<RecipeCategory> categories = RecipeCategory.getRecipeCategory();
  RecipeCategory findCategory(int id) =>
      categories.firstWhere((RecipeCategory) => RecipeCategory.id == id);
  @override
  void initState() {
    helper = DataBaseHelper();
    helper.getRecipes().then((recipes) {
      setState(() {
        recipeList = recipes;
        allrecipe = recipes;
        print(recipeList);
      });
    });
    super.initState();
  }

  void filterRecipeSeach(String query) async {
    var dummySearchList = recipeList;
    if (query.isNotEmpty) {
      var dummyListData = <dynamic>[];
      dummySearchList.forEach((item) {
        var My_recipe = Recipe.fromMap(item);
        if (My_recipe.RecipeName.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
          print(
            'My_recipe.itemName.toLowerCase().${My_recipe.RecipeName.toLowerCase()}',
          );
        }
      });
      setState(() {
        recipeList = [];
        recipeList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        recipeList = [];
        recipeList.addAll(allrecipe);
      });
    }
  }

  void filterRecipeByCategory(int categoyId) {
    var dummySearchList = allrecipe;

    var dummyListData = <dynamic>[];
    dummySearchList.forEach((item) {
      var My_recipe = Recipe.fromMap(item);
      if (My_recipe.RecipeCategoryId == categoyId) {
        dummyListData.add(item);
      }
    });
    setState(() {
      print('hallo');
      recipeList = [];
      recipeList.addAll(dummyListData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              filterRecipeSeach(value);
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search),
            // hintText: ' ${DemoLocalization.of(context)!.translate('Search')}',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 5.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colors.blue, // بدل primary
                      // primary: Color.fromARGB(255, 160, 101, 170)),
                    ),
                    onPressed: () {
                      setState(() {
                        filterRecipeByCategory(categories[index].id);
                      });
                    },
                    child: Text(
                      (widget._locale!.languageCode == 'ar')
                          ? '${categories[index].name_ar}'
                          : (widget._locale!.languageCode == 'de')
                          ? '${categories[index].name_de}'
                          : '${categories[index].name}',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              },
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100,
                childAspectRatio: 8 / 8,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: recipeList.length,
              itemBuilder: (BuildContext context, int index) {
                Recipe recipe = Recipe.fromMap(recipeList[index]);
                return Container(
                  height: 50,
                  margin: EdgeInsets.all(2),
                  child: ListTile(
                    onTap: () {
                      selectRecipe(
                        context,
                        recipe.RecipeId,
                        recipe.RecipeName,
                        recipe.Description,
                        recipe.category_id,
                        recipe.RecipeItems,
                      );
                    },
                    title: Text(' ${recipe.RecipeName} '),
                    subtitle: Text(
                      (widget._locale!.languageCode == 'ar')
                          ? '${findCategory(recipe.category_id).name_ar}'
                          : (widget._locale!.languageCode == 'de')
                          ? '${findCategory(recipe.category_id).name_de}'
                          : '${findCategory(recipe.category_id).name}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.navigate_next),
                      onPressed: () {
                        selectRecipe(
                          context,
                          recipe.RecipeId,
                          recipe.RecipeName,
                          recipe.Description,
                          recipe.category_id,
                          recipe.RecipeItems,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => add_recipe_screen(widget._locale),
                ),
              )
              .then(
                (value) => {
                  helper.getRecipes().then((recipes) {
                    setState(() {
                      recipeList = recipes;
                      allrecipe = recipes;
                      print(recipeList);
                    });
                  }),
                },
              );
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }

  void selectRecipe(
    BuildContext ctx,
    int id,
    String name,
    String Description,
    int category_id,
    String Recipes_items,
  ) {
    Navigator.of(ctx)
        .pushNamed(
          view_recipe_screen.screenRoute,
          arguments: {
            'recipe_id': id.toString(),
            'recipe_name': name,
            'recipe_Description': Description,
            'recipe_category_id': category_id.toString(),
            'recipes_items': Recipes_items.toString(),
          },
        )
        .then(
          (value) => {
            helper.getRecipes().then((recipes) {
              setState(() {
                recipeList = recipes;
                allrecipe = recipes;
                print(recipeList);
              });
            }),
          },
        );
  }
}
