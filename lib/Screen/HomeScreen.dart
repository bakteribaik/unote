import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:unote/Models/notes_models.dart';
import 'package:unote/Screen/EditORaddNote.dart';
import 'package:unote/Service/db_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePages extends StatefulWidget {
  const HomePages({Key? key}) : super(key: key);

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {

  late List<Note> notes;
  List<Note> result = [];

  bool isLoading = false;
  String query = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() {
      isLoading = true;
    });

    this.notes = await NotesDatabase.instance.readAllNotes();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: Color(0xFF222831),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('unote', style: TextStyle(color: Colors.lightBlue[50], fontSize: 24),),
      ),
      body: Container(  
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Center(
              child: Container(
                  padding: EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 5),
                  width: MediaQuery.of(context).size.width/1.2,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(57, 177, 208, 224),
                    borderRadius: BorderRadius.circular(50)
                  ),
                  child: Row(
                    children: [
                      // CircleAvatar(),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            onChanged: (value){
                              setState(() {
                                query  = value;
                                print(query);
                                _searchResult(query);
                              });
                            },
                            style: TextStyle(color: Colors.white54),
                            decoration: InputDecoration(
                              hintText: 'Search note',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.white54)
                            ),
                          )
                        )
                      ),
                      Icon(Icons.search, color: Colors.white54,)
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20,),

              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child:  isLoading ? CircularProgressIndicator() : 
                      notes.isEmpty ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('write something so you don`t forget', style: TextStyle(color: Colors.lightBlue[100], fontWeight: FontWeight.bold, fontSize: 18),textAlign: TextAlign.center,),
                          SizedBox(height: 3,),
                          Text('Pro tip: long press on note, for more menu', style: TextStyle(color: Colors.lightBlue[300], fontSize: 11, fontStyle: FontStyle.italic),textAlign: TextAlign.center,),
                          SizedBox(height: 10,),
                          Text('if you like my work, you can support me with\ntap on coffe button down below', style: TextStyle(color: Colors.lightBlue[100], fontSize: 9),textAlign: TextAlign.center,)
                        ],
                      ),) :
                        query.isEmpty ? _buildNotes() : _onSearch()
                  ),
                ),
              ),
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        isExtended: true,
        onPressed: () async {
          FocusScope.of(context).unfocus();
          await Navigator.push(context,
          MaterialPageRoute(builder: (context) => AddEditPages()));
          refreshNotes();
        },
        child: Icon(Icons.add, size: 30,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Color.fromARGB(255, 91, 105, 112),
          child: Container(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final result = await InternetConnectionChecker().hasConnection;
                    if (result == true) {
                      launchUrl(Uri.parse('https://linktr.ee/zeday'));
                    }else{
                      Fluttertoast.showToast(
                        backgroundColor: Color(0xFF222831),
                        msg: 'No Internet Connection',
                      );
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Icon(Icons.coffee_outlined, color: Colors.white,)
                  ),
                ),
              ],
            ),
          ),
          notchMargin: 8,
        ),
      )
    );
  }

  _searchResult(String input){
    result = notes.where((data) => data.title.toLowerCase().contains(input.toLowerCase())).toList();
    if (result.isEmpty) {
      result = notes.where((data) => data.description.toLowerCase().contains(input.toLowerCase())).toList();
    }
  }

  _onSearch() => MasonryGridView.count(
    padding: EdgeInsets.all(8),
    crossAxisCount: 2,
    crossAxisSpacing: 4,
    mainAxisSpacing: 4,
    
    itemCount: result.length,
    itemBuilder: (context, index){
      final note = result[index];

      return GestureDetector(
        onLongPress: () async {
          FocusScope.of(context).unfocus();
          HapticFeedback.vibrate();
          showModalBottomSheet<dynamic>(
            backgroundColor: Colors.transparent,                                                                
            context: context, 
            builder: (context){
              return FractionallySizedBox(                                                            
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                  ),
                  child: Wrap(                                                                                                                                                    
                    direction: Axis.vertical,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [                                                                                    
                      TextButton(onPressed: () async {
                        if (note.isImportant == true) {
                          Navigator.of(context).pop();
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                              title: Text('Deleting important note!', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.lightBlue[300]),),
                              content: Text('are you sure want to delete the important note?', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.lightBlue[200]),),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }, child: Text('No', style: TextStyle(color: Colors.lightBlue),)),
                                TextButton(
                                  onPressed: () async {
                                    await NotesDatabase.instance.delete(note.id!);
                                    refreshNotes();
                                    Navigator.of(context).pop();
                                    Fluttertoast.showToast(
                                      backgroundColor: Color(0xFF222831),
                                      msg: 'Note Deleted!',
                                    );
                                  }, child: Text('Yes', style: TextStyle(color: Colors.lightBlue),))
                              ],
                            );
                          });
                        }else{
                          await NotesDatabase.instance.delete(note.id!);
                          refreshNotes();
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                            backgroundColor: Color(0xFF222831),
                            msg: 'Note Deleted!',
                          );
                        }
                      }, child: Text('Delete note', style: TextStyle(color: Colors.lightBlue[300]),)),

                      note.isImportant ?

                      TextButton(onPressed: () async {
                        await NotesDatabase.instance.update(
                          note.copy(isImportant: false)
                        );
                        Navigator.of(context).pop();
                        refreshNotes();
                      }, child: Text('Unpin Note', style: TextStyle(color: Colors.lightBlue[300]),)) :

                      TextButton(onPressed: () async {
                        await NotesDatabase.instance.update(
                          note.copy(isImportant: true)
                        );
                        Navigator.of(context).pop();
                        refreshNotes();
                      }, child: Text('Pin Note', style: TextStyle(color: Colors.lightBlue[300]),)),
                    ],
                  ),
                ),
              );
            }
          );
        },
        onTap: () async {
          FocusScope.of(context).unfocus();
          await Navigator.push(context,
          MaterialPageRoute(builder: (context) => AddEditPages(note: note,)));
          refreshNotes();
        },
        child: Container(
          padding: EdgeInsets.only(top: 20, bottom: 20, right: 20, left: 20),
          height: 200,
          decoration: BoxDecoration(
            color: note.isImportant == true ? Colors.lightBlue[300] : Color.fromARGB(57, 177, 208, 224),
            borderRadius: BorderRadius.circular(25)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              note.isImportant ?
              Container(
                padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
                margin: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text('pinned',style: TextStyle(color: Colors.black54, fontSize: 10),)
                    ),
                    // SizedBox(width: 5,),
                    // CircleAvatar(backgroundColor: Colors.red, radius: 3,),
                    
                  ],
                )
              ) : SizedBox(),

              Text(note.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, overflow: TextOverflow.ellipsis, color: Colors.lightBlue[50]),),
              SizedBox(height: 10,),
              Expanded(
                child: Container(
                  child: Text(
                    note.description.length > 90 ? note.description.substring(0, 90) + '...' : note.description,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  )
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                height: 20,
                width: MediaQuery.of(context).size.width,
                child: Text(DateFormat('EEE, dd MMMM yyyy').format(note.createdTime), style: TextStyle(color: Colors.lightBlue[50], overflow: TextOverflow.ellipsis, fontSize: 10, ),),
              )
            ],
          ),
        ),
      );
    },
  );

   _buildNotes() => MasonryGridView.count(
    padding: EdgeInsets.all(8),
    crossAxisCount: 2,
    crossAxisSpacing: 4,
    mainAxisSpacing: 4,
    
    itemCount: notes.length,
    itemBuilder: (context, index){
      final note = notes[index];

      return GestureDetector(
        onLongPress: () async {
          FocusScope.of(context).unfocus();
          HapticFeedback.vibrate();
          showModalBottomSheet<dynamic>(
            backgroundColor: Colors.transparent,                                                                
            context: context, 
            builder: (context){
              return FractionallySizedBox(                                                            
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                  ),
                  child: Wrap(                                                                                                                                                    
                    direction: Axis.vertical,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [                                                                                    
                      TextButton(onPressed: () async {
                        if (note.isImportant == true) {
                          Navigator.of(context).pop();
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                              title: Text('Deleting important note!', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.lightBlue[300]),),
                              content: Text('are you sure want to delete the important note?', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.lightBlue[200]),),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }, child: Text('No', style: TextStyle(color: Colors.lightBlue),)),
                                TextButton(
                                  onPressed: () async {
                                    await NotesDatabase.instance.delete(note.id!);
                                    refreshNotes();
                                    Navigator.of(context).pop();
                                    Fluttertoast.showToast(
                                      backgroundColor: Color(0xFF222831),
                                      msg: 'Note Deleted!',
                                    );
                                  }, child: Text('Yes', style: TextStyle(color: Colors.lightBlue),))
                              ],
                            );
                          });
                        }else{
                          await NotesDatabase.instance.delete(note.id!);
                          refreshNotes();
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                            backgroundColor: Color(0xFF222831),
                            msg: 'Note Deleted!',
                          );
                        }
                      }, child: Text('Delete note', style: TextStyle(color: Colors.lightBlue[300]),)),

                      note.isImportant ?

                      TextButton(onPressed: () async {
                        await NotesDatabase.instance.update(
                          note.copy(isImportant: false)
                        );
                        Navigator.of(context).pop();
                        refreshNotes();
                      }, child: Text('Unpin Note', style: TextStyle(color: Colors.lightBlue[300]),)) :

                      TextButton(onPressed: () async {
                        await NotesDatabase.instance.update(
                          note.copy(isImportant: true)
                        );
                        Navigator.of(context).pop();
                        refreshNotes();
                      }, child: Text('Pin Note', style: TextStyle(color: Colors.lightBlue[300]),)),
                    ],
                  ),
                ),
              );
            }
          );
        },
        onTap: () async {
          FocusScope.of(context).unfocus();
          await Navigator.push(context,
          MaterialPageRoute(builder: (context) => AddEditPages(note: note,)));
          refreshNotes();
        },
        child: Container(
          padding: EdgeInsets.only(top: 20, bottom: 20, right: 20, left: 20),
          height: 200,
          decoration: BoxDecoration(
            color: note.isImportant == true ? Colors.lightBlue[300] : Color.fromARGB(57, 177, 208, 224),
            borderRadius: BorderRadius.circular(25)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              note.isImportant ?
              Container(
                padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
                margin: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text('pinned',style: TextStyle(color: Colors.black54, fontSize: 10),)
                    ),
                    // SizedBox(width: 5,),
                    // CircleAvatar(backgroundColor: Colors.red, radius: 3,),
                    
                  ],
                )
              ) : SizedBox(),

              Text(note.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, overflow: TextOverflow.ellipsis, color: Colors.lightBlue[50]),),
              SizedBox(height: 10,),
              Expanded(
                child: Container(
                  child: Text(
                    note.description.length > 90 ? note.description.substring(0, 90) + '...' : note.description,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  )
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                height: 20,
                width: MediaQuery.of(context).size.width,
                child: Text(DateFormat('EEE, dd MMMM yyyy').format(note.createdTime), style: TextStyle(color: Colors.lightBlue[50], overflow: TextOverflow.ellipsis, fontSize: 10, ),),
              )
            ],
          ),
        ),
      );
    },
  );
}
