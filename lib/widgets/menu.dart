import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:little_daffy/pages/home/principal.dart';
import 'package:little_daffy/routes/routes.dart';
import 'package:little_daffy/utils/app_colors.dart';


class MenuPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: Column(
          children: <Widget>[
            SafeArea(
              child: Container(
                decoration: BoxDecoration(gradient: bgGrad()),
                padding: EdgeInsets.all(35),
                width: double.infinity,
                height: 200,
                child: CircleAvatar(
                  child: Text(
                    'LD',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ),
            Container(
              // color: Colors.transparent,
              child: Expanded(child: ListaBotones()),
            )
          ],
        ),
      ),
    );
  }
}

class ListaBotones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: bgGradient()),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        separatorBuilder: (context, i) => Divider(
          color: Colors.black,
        ),
        itemCount: pageRoutes.length,
        itemBuilder: (context, i) => ListTile(
          tileColor: Colors.transparent,
          leading: Icon(pageRoutes[i].icon, color: Colors.blue),
          title:
              Text(pageRoutes[i].titulo, style: TextStyle(color: Colors.black)),
          trailing: Icon(Icons.chevron_right, color: Colors.blue),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => pageRoutes[i].page));
          },
        ),
      ),
    );
  }
}

bgGrad() {
  return LinearGradient(colors: [
    AppColors.primary,
    Color(0xffffffff),
  ], begin: Alignment.center, end: Alignment.bottomCenter);
}