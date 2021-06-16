import 'package:flutter/material.dart';
import 'package:little_daffy/pages/adopcion/widgets/pet_adoption_widget.dart';
import 'package:little_daffy/pages/home/category_list.dart';
import 'package:little_daffy/pages/home/data.dart';
import 'package:little_daffy/routes/routes.dart';
import 'package:little_daffy/utils/app_colors.dart';

class AdopcionPage extends StatefulWidget {
  @override
  _AdopcionPageState createState() => _AdopcionPageState();
}

class _AdopcionPageState extends State<AdopcionPage> {

  List<Pet> pets = getPetList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("LITTLE DAFFY"),
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: _MenuPrincipal(),
      
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding( 
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(" "),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Mascotas en adopcion",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 24,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Categoria de mascotas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),

                  Icon(
                    Icons.more_horiz,
                    color: Colors.grey[800],
                  ),

                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildPetCategory(Category.HAMSTER, "56", Colors.orange[200]),
                      buildPetCategory(Category.CAT, "210", Colors.blue[200]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildPetCategory(Category.BUNNY, "90", Colors.green[200]),
                      buildPetCategory(Category.DOG, "340", Colors.red[200]),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Nuevas publicaciones",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 500,
              child: ListView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: buildNewestPet(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPetCategory(Category category, String total, Color color){
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryList(category: category)),
          );
        },
        child: Container(
          height: 80,
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[200],
              width: 1,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Row(
            children: [

              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.5),
                ),
                child: Center(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      "assets/pages/home/" + (category == Category.HAMSTER ? "hamster" : category == Category.CAT ? "cat" : category == Category.BUNNY ? "bunny" : "dog") + ".png",
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 12,
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    category == Category.HAMSTER ? "Hamsters" : category == Category.CAT ? "Cats" : category == Category.BUNNY ? "Bunnies" : "Dogs",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Total of " + total,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildNewestPet(){
    List<Widget> list = [];
    for (var i = 0; i < pets.length; i++) {
      if(pets[i].newest){
        list.add(
          PetWidget(
            pet: pets[i], 
            index: i
          )
        );
      }
    }
    return list;
  }

  Widget buildVet(String imageUrl, String name, String phone){
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
        border: Border.all(
          width: 1,
          color: Colors.grey[300],
        ),
      ),
      child: Row(
        children: [

          Container(
            height: 98,
            width: 98,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(
            width: 16,
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                name,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(
                height: 8,
              ),

              Row(
                children: [

                  Icon(
                    Icons.phone,
                    color: Colors.grey[800],
                    size: 18,
                  ),

                  SizedBox(
                    width: 8,
                  ),

                  Text(
                    phone,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),

              SizedBox(
                height: 8,
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  "OPEN - 24/7",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

}

class _MenuPrincipal extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){
    return Drawer(
          child: Container(
        child: Column(
          children: <Widget>[
            SafeArea(
              child: Container(
                color: AppColors.primary,
                padding: EdgeInsets.all(35),
                width: double.infinity,
                height: 200,
                child: CircleAvatar(
                  child: Text('LD', 
                    style: TextStyle(fontSize: 50), 
                  ), 
                ),
              ),
            ),
            Container(
              // color: Colors.transparent,
              child: Expanded(
                child: _ListaBotones()
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ListaBotones extends StatelessWidget{

  @override
  Widget build(BuildContext context){

    

    return Container(
      decoration: new BoxDecoration (
                color: AppColors.primary
      ),
      child: ListView.separated(
        
        physics: BouncingScrollPhysics(),
        separatorBuilder: (context, i) => Divider(
          color: Colors.black,
        ),
        itemCount: pageRoutes.length,
        itemBuilder: (context, i) => ListTile(
          tileColor: Colors.transparent,
          leading: Icon(pageRoutes[i].icon, color: Colors.blue),
          title: Text(pageRoutes[i].titulo, style: TextStyle(color: Colors.black)),
          trailing: Icon(Icons.chevron_right, color: Colors.blue),
          onTap: (){
            Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => pageRoutes[i].page)
            );
          },

        ),
      ),
    );
  }
}