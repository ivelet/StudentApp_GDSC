import 'package:flutter/material.dart';
import 'database_helper.dart';

class CreateTopicScreen extends StatefulWidget {
  final int parentId;

  const CreateTopicScreen({Key? key, required this.parentId}) : super(key: key);

  @override
  _CreateTopicScreenState createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _chapterController = TextEditingController();
  final _rankingController = TextEditingController();
  final _notesController = TextEditingController();
  final _materialController = TextEditingController();

  void _saveTopic() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Add parent id and also based on that determine and add type to 
      //differentiate between topic and chapter
      // TODO: modify courseId so that not just parentId
      await DatabaseHelper.instance.createTopic({
        'name': _nameController.text,
        'courseId': widget.parentId,
        'parentId': widget.parentId,
        'chapter': _chapterController.text,
        'ranking': int.tryParse(_rankingController.text) ?? 0,
        'notes': _notesController.text,
        'material': _materialController.text
      });

      Navigator.of(context).pop(); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Topic'),
      ),
      body: Form(
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
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _chapterController,
                decoration: InputDecoration(labelText: 'Full topic index e.g. 1.2.3'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the topic index';
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
              ElevatedButton(
                onPressed: _saveTopic,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
