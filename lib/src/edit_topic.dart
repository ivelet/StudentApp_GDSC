import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'topic.dart';

class EditTopicScreen extends StatefulWidget {
  final int topicId;

  const EditTopicScreen({Key? key, required this.topicId}) : super(key: key);

  @override
  _EditTopicScreenState createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _chapterController = TextEditingController();
  late TextEditingController _rankingController = TextEditingController();
  late TextEditingController _notesController = TextEditingController();
  late TextEditingController _materialController = TextEditingController();
  late Future<Topic> _topicFuture;

  @override
  void initState() {
    super.initState();
    _topicFuture = DatabaseHelper.instance.getTopicById(widget.topicId);
    _topicFuture.then((topic) {
      _nameController.text = topic.name;
      _chapterController.text = topic.chapter;
      _rankingController.text = topic.ranking.toString();
      _notesController.text = topic.notes;
      _materialController.text = topic.material;
    });
  }

  void _updateTopic(Topic topic) async {
    if (_formKey.currentState!.validate()) {
      await DatabaseHelper.instance.updateTopic({
        'id': topic.id,
        'name': _nameController.text,
        'courseId': topic.parentId, // Assuming courseId is needed, adjust as necessary
        'parentId': topic.parentId,
        'chapter': _chapterController.text,
        'ranking': int.tryParse(_rankingController.text) ?? 0,
        'notes': _notesController.text,
        'material': _materialController.text,
      });

      Navigator.of(context).pop(); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Topic>(
          future: _topicFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Edit Topic - ${snapshot.data!.name}');
            } else {
              return Text('Edit Topic');
            }
          },
        ),
      ),
      body: FutureBuilder<Topic>(
        future: _topicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Topic Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a topic name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _chapterController,
                      decoration: InputDecoration(labelText: 'Full topic index e.g. 1.2.3'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the topic chapter';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _rankingController,
                      decoration: InputDecoration(labelText: 'Rank your understanding of the topic (1-10)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the ranking';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(labelText: 'Add any notes, questions, or doubts here'),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _materialController,
                      decoration: InputDecoration(labelText: 'Add any relevant material and resources here'),
                      validator: (value) {
                        return null;
                      },
                    ),
                    // Add other TextFormField widgets here
                    ElevatedButton(
                      onPressed: () => _updateTopic(snapshot.data!),
                      child: Text('Update'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Text('No topic found.');
          }
        },
      ),
    );
  }
}
