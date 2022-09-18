import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:unote/Models/notes_models.dart';
import 'package:unote/Service/db_helper.dart';

class AddEditPages extends StatefulWidget {

  final Note? note;

  const AddEditPages({Key? key, this.note}) : super(key: key);

  @override
  State<AddEditPages> createState() => _AddEditPagesState();
}

class _AddEditPagesState extends State<AddEditPages> {

  late bool isImportant;
  late int number;
  late String title;
  late String description;

  bool important = false;
  String query = '';

  TextEditingController titleC = TextEditingController();
  TextEditingController descC = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isImportant = widget.note?.isImportant ?? false;
    number = widget.note?.number ?? 0;
    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';

    if (widget.note != null) {
      titleC.text = '${widget.note?.title}';
      descC.text = '${widget.note?.description}';
      important = widget.note!.isImportant;
    }
  } 

  addorupdate() async {
    final isUpdateing = widget.note != null;

    if (isUpdateing) {
      updateNote();
    }else{
      addNote();
    }
    Navigator.of(context).pop();
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      isImportant: important,
      number: number,
      title: titleC.text,
      description: descC.text
    );

    await NotesDatabase.instance.update(note);
    Fluttertoast.showToast(
      backgroundColor: Color(0xFF222831),
      msg: 'Note updated!',
    );
  }

  Future addNote() async {
    final note = Note(
      isImportant: important,
      number: number,
      title: titleC.text,
      description: descC.text,
      createdTime: DateTime.now(),
    );

    await NotesDatabase.instance.create(note);
    Fluttertoast.showToast(
      backgroundColor: Color(0xFF222831),
      msg: 'New note added!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222831),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          query.isEmpty && widget.note == null ? SizedBox() :
          IconButton(
            onPressed: (){
              addorupdate();
            }, 
            icon: Icon(Icons.check)
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 135,
                height: 30,
                padding: EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.lightBlue[50]
                ),
                child: Row(
                  children: [
                    Text('Important?', style: TextStyle(fontWeight: FontWeight.bold, color: important ? Colors.lightBlue : Colors.black54),),
                    Checkbox(
                      value: important, 
                      onChanged: (value){
                        setState(() {
                          important = value!;
                        });
                      })
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Container(
                height: 80,
                child: TextField(
                  controller: titleC,
                  cursorColor: Colors.white,
                  onChanged: (value){
                    setState(() {
                      query = value;
                    });
                  },
                  style: TextStyle(fontSize: 25, color: Colors.white60, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Title..',
                    hintStyle: TextStyle(fontSize: 25, color: Colors.white60, fontWeight: FontWeight.bold),
                    border: InputBorder.none
                  ),
                ),
              ),
              Container(
                child: widget.note != null ? 
                  Text('Created on: ${DateFormat('EEE, dd MMMM yyyy').format(widget.note!.createdTime)}', style: TextStyle(color: Colors.white),) :
                  Text(DateFormat('EEE, dd MMMM yyyy').format(DateTime.now()), style: TextStyle(color: Colors.white),),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: descC,
                    textInputAction: TextInputAction.newline,
                    minLines: 1,
                    maxLines: null,
                    onChanged: (value){
                    setState(() {
                        query = value;
                      });
                    },
                    style: TextStyle(fontSize: 18, color: Colors.white60),
                    decoration: InputDecoration(
                    hintText: 'Write something...',
                    hintStyle: TextStyle(fontSize: 18, color: Colors.white60),
                    border: InputBorder.none
                  ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      //   child: Container(
      //     padding: EdgeInsets.only(left: 10),
      //     height: 50,
      //     child: Row(
      //       children: [
      //         GestureDetector(
      //           onTap: () {
      //             setState(() {
      //               color1 = 0xFFFFFFFF;
      //             });
      //           },
      //           child: CircleAvatar(
      //             radius: 15,
      //             backgroundColor: Colors.red,
      //           ),
      //         ),
      //         SizedBox(width: 10,),
      //         GestureDetector(
      //           onTap: () {
      //             setState(() {
      //               color1 = 0xFFFFFFFF;
      //             });
      //           },
      //           child: CircleAvatar(
      //             radius: 15,
      //             backgroundColor: Colors.yellow,
      //           ),
      //         ),
      //         SizedBox(width: 10,),
      //         GestureDetector(
      //           onTap: () {
      //             setState(() {
      //               color1 = 0xFFFFFFFF;
      //             });
      //           },
      //           child: CircleAvatar(
      //             radius: 15,
      //             backgroundColor: Colors.green,
      //           ),
      //         ),
      //         SizedBox(width: 10,),
      //         GestureDetector(
      //           onTap: () {
      //             setState(() {
      //               color1 = 0xFFFFFFFF;
      //             });
      //           },
      //           child: CircleAvatar(
      //             radius: 15,
      //             backgroundColor: Colors.blue,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // )
    );
  }
}