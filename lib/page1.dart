import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main()
{
    runApp(MaterialApp(
       home: page1(),debugShowCheckedModeBanner: false,
    ));
}
class page1 extends StatefulWidget {
  // const page1({super.key});
  static Database? database;

  @override
  State<page1> createState() => _page1State();
}

class _page1State extends State<page1> {

  String name ="";
  List l = [];
  bool t =false;
  bool t2 = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get();
  }

  get_data()
  async {
      String qry = "select * from add_table";
      l = await page1.database!.rawQuery(qry);
      print("l : $l");
      setState(() { });
  }

  get()
  async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

// Delete the database
//     await deleteDatabase(path);

// open the database
     page1.database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE add_table (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
        });

  }

  TextEditingController t1 = TextEditingController();


  @override
  Widget build(BuildContext context) {


    add_new()
    {
      t1.text="";
      showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0)),
        ),
        isDismissible: false,
        context: context,
        builder: (context) {
          return Container(
              height: (t2)?500:300,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              // color: Colors.red,
              child: Column(children: [
                AppBar(
                  backgroundColor: Colors.white,
                  leading: IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.close,color: Colors.black,)),
                  title: Text("Add new category",style: TextStyle(color: Colors.black),),
                ),
                SizedBox(height: 20,),
                Container(
                  height: 90,
                  child: TextField(
                    onTap: () {
                      t2 = true;


                    setState(() { });
                  },
                    controller: t1,
                    decoration: InputDecoration(
                      hintText: "Enter Category",
                      errorText: (t)?"This field is required":"",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  height: 70,
                  padding: EdgeInsets.all(10),
                  child: GFButton(
                    onPressed: () async {
                          name = t1.text;
                          if(t1.text=="")
                          {
                             t=false;
                          }
                          else
                          {
                             t=true;
                             String qry = "insert into add_table VALUES(null, '$name')";
                             await page1.database?.rawInsert(qry);
                          }
                        // String qry = "insert into add_table VALUES(null, '$name')";
                        // await page1.database?.rawInsert(qry);

                        // print(qry);
                        Navigator.pop(context);
                        // t = true;
                        t2=false;
                        setState(() { });
                    },
                    text: " + Add New Category",
                    textStyle: TextStyle(fontSize: 20),
                    fullWidthButton: true,
                  ),
                ),
                // (t2)?Container(
                //   height: 100,
                //   // color: Colors.red,
                // ):Text(""),
              ],)
          );
        },
      );
      setState(() { });
    }


    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Setting",style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ),
        body: Column(children: [
          ListTile(
            title: Row(children: [
              Text("Category"),
              IconButton(onPressed: (){
                add_new();
                setState(() { });
              }, icon: Icon(Icons.add_circle_sharp)),
            ]),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              child: FutureBuilder(
                future: get_data(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting)
                  {
                    return GridView.builder(
                      itemCount: l.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 40,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          height: 10,width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey,width: 2,),borderRadius: BorderRadius.circular(5),),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                            InkWell(
                              onTap: () {
                                showDialog(barrierDismissible: false,
                                    context: context, builder: (context) {
                                      return AlertDialog(
                                        title: Text("Delete Category ${l[index]['name']} ?"),
                                        actions: [
                                          TextButton(onPressed: (){
                                            Navigator.pop(context);
                                          }, child: Text("No",style: TextStyle(color: Colors.blue),)),
                                          TextButton(onPressed: () async {
                                            String qry = 'DELETE FROM add_table WHERE id = ${l[index]['id']}';
                                            await page1.database!.rawDelete(qry);
                                            Navigator.pop(context);
                                            setState(() { });
                                          }, child: Text("Yes",style: TextStyle(color: Colors.red),)),
                                        ],
                                      );
                                    });
                              },
                              child: Container(height: 30,width: 30,
                                decoration: BoxDecoration(color: Colors.deepPurpleAccent,shape: BoxShape.circle),
                                // alignment: Alignment.center,
                                child: Icon(Icons.close,color: Colors.white,),
                              ),
                            ),
                            Text("${l[index]['name']}")
                          ]),
                        );
                      },
                    );
                  }
                  else
                  {
                    return Center(child: CircularProgressIndicator(),);
                  }
                },
              ),
            ),
          )
        ]),
      ),
    );
  }
}
