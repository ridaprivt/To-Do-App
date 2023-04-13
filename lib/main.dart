// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ToDoDataBase.dart';

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('mybox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return GetMaterialApp(
          debugShowCheckedModeBanner: false, home: HomePage());
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  final _controller = TextEditingController();

  void initState() {
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();
  }

  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFa7cab1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF310a31),
        onPressed: createNewTask,
        child: Icon(Icons.add),
      ),
      body: ListView(
        padding: EdgeInsets.all(0),
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 1.5.h),
            height: 25.h,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(color: Color(0xFF310a31)),
            child: Text('To-Do App',
                style: GoogleFonts.roboto(
                    textStyle:
                        TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800),
                    color: Colors.white)),
          ),
          Container(
            height: 75.h,
            child: ListView.builder(
              itemCount: db.toDoList.length,
              itemBuilder: (context, index) {
                return ToDoTile(
                  taskName: db.toDoList[index][0],
                  taskCompleted: db.toDoList[index][1],
                  onChanged: (value) => checkBoxChanged(value, index),
                  deleteFunction: (context) => deleteTask(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DialogBox extends StatelessWidget {
  final controller;
  VoidCallback onSave;
  VoidCallback onCancel;

  DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF847996),
      content: Container(
        height: 20.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // get user input
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(15.sp),
                border: Border.all(
                    width: 0.2.w, color: Color.fromARGB(255, 206, 206, 206)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: Offset(5, 12), // changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                obscureText: false,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.5.sp),
                decoration: InputDecoration(
                  hintText: 'Add a Task',
                  contentPadding: EdgeInsets.only(
                      top: 0.h, bottom: 1.h, left: 2.5.w, right: 2.w),
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.5.sp),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(0, 255, 255, 255))),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Color.fromARGB(0, 255, 255, 255),
                  )),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),

            Row(
              children: [
                MyButton(text: "Save", onPressed: onSave),
                MyButton(text: "Cancel", onPressed: onCancel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final String text;
  VoidCallback onPressed;
  MyButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: 10.0,
      onPressed: onPressed,
      child: Container(
        width: 24.w,
        margin: EdgeInsets.all(0),
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 2.w),
        height: 5.5.h,
        decoration: BoxDecoration(
          color: Color(0xFF310a31),
          borderRadius: BorderRadius.circular(13.sp),
          border:
              Border.all(width: 0.2.w, color: Color.fromARGB(255, 84, 24, 84)),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(199, 140, 140, 140).withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Text(text,
            style: GoogleFonts.roboto(
                textStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))),
      ),
    );
  }
}

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;

  ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 3.h),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Color.fromARGB(255, 133, 38, 38),
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFFf4ecd6),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(199, 140, 140, 140).withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(15.sp),
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: 4.5.sp,
                child: Checkbox(
                  value: taskCompleted,
                  onChanged: onChanged,
                  activeColor: Color(0xFF310a31),
                  side: BorderSide(width: 4.sp),
                ),
              ),
              Text(taskName,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w400,
                    decoration: taskCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ))),
            ],
          ),
        ),
      ),
    );
  }
}
