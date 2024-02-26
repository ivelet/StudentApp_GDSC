import 'package:flutter/material.dart';
import 'package:student_app/src/create_course.dart';
import 'package:student_app/src/topics.dart';
import 'course.dart';
import 'database_helper.dart';
import 'create_course.dart';
import 'gpt_service.dart';

class CoursesListView extends StatefulWidget {
  @override
  _CoursesListViewState createState() => _CoursesListViewState();
}

class _CoursesListViewState extends State<CoursesListView> {
  late Future<List<Course>> courses;

  @override
  void initState() {
    super.initState();
    courses = DatabaseHelper.instance.getCourses();
  }

  void _addCourse() async {
    // TODO: replace hard-coded values for entry
    // await DatabaseHelper.instance.createCourse({
    //   'name': 'New Course',
    //   'credits': 6,
    // });

    // setState(() {
    // courses = DatabaseHelper.instance.getCourses();
    // });

    // Navigate to the NewCourseScreen to add a new course

  }

  void _testGPTAPI() async {
  final messages = [
    {"role": "system", "content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."},
    {"role": "user", "content": "Compose a poem that explains the concept of recursion in programming."}
  ];

  try {
    final gptService = GPTService(); // Ensure you have an instance of your GPT service
    final response = await gptService.generateResponse("hello");
    _showResponseDialog(response);
  } catch (e) {
    print("Error calling GPT API: $e");
    _showResponseDialog("Failed to get response from GPT API. Error: $e");
  }
}

void _showResponseDialog(String response) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('GPT API Response'),
        content: SingleChildScrollView(
          child: Text(response),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.send),
          onPressed: (){
            _testGPTAPI();
          },)
        ]
      ),
      body: FutureBuilder<List<Course>>(
        future: courses,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Course course = snapshot.data![index];
                return ListTile(
                  title: Text(course.name),
                  subtitle: Text("Credits: ${course.credits}"),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TopicsScreen(
                          parentId: course.id, 
                          title: course.name))
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: (){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CreateCourseScreen()),
        ).then((_){
          setState(() {
            courses = DatabaseHelper.instance.getCourses();
          });
        });
      },
      tooltip: 'Add a new course',
      child: Icon(Icons.add), 
      ),
    );
  }
}
