import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'topic.dart'; 
import 'create_topic.dart';
import 'edit_topic.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class TopicsScreen extends StatefulWidget {
  // parentId is the id of the parent of the current topics ie. the id of title
  final int parentId;
  final String title;

  const TopicsScreen({Key? key, required this.parentId, required this.title}) : super(key: key);

  @override
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  late Future<List<Topic>> topics;
  // Init a QuillController
  late quill.QuillController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    topics = DatabaseHelper.instance.getTopics(widget.parentId);
    _controller =  quill.QuillController.basic();
    _focusNode = FocusNode();
    _focusNode.addListener((){
      if (_focusNode.hasFocus) {
        showModalBottomSheet(
          context: context, 
          builder: (context) => quill.QuillToolbar.simple(
                  configurations: quill.QuillSimpleToolbarConfigurations(
                    controller: _controller,
                    sharedConfigurations: const quill.QuillSharedConfigurations(
                      locale: Locale('en'),
                      )
                    )
                  ),
          isScrollControlled: true,
          );
      }
    });
  }

  void _confirmDeletion(Topic topic) {
  // This captures the context before the async gap.
  final BuildContext dialogContext = context;

  showDialog(
    context: dialogContext,
    builder: (BuildContext context) {
      // Dialog builder context is used here, safe across async gaps.
      return AlertDialog(
        title: Text('Delete Topic'),
        content: Text('This topic will be deleted.'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog using dialog context
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog using dialog context
              // Call delete method outside of this builder to avoid async gap issues.
              await _deleteTopic(topic.id);
            },
          ),
        ],
      );
    },
  );
}

Future<void> _deleteTopic(int topicId) async {
  // Perform deletion and UI update here.
  // This method is not directly tied to the widget's build method context.
  await DatabaseHelper.instance.deleteTopic(topicId);
  setState(() {
    topics = DatabaseHelper.instance.getTopics(widget.parentId);
  });
}

Widget _buildTopicItem(Topic topic) {
  Color getRankingColor(int ranking) {
    // Adjust the color range as per your preference
    if (ranking <= 3) return Colors.red;
    if (ranking <= 6) return Colors.orange;
    if (ranking <= 10) return Colors.green;
    return Colors.grey; // Default color
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        Expanded(
          child: Text(
            "${topic.chapter} - ${topic.name}",
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: getRankingColor(topic.ranking),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "${topic.ranking}",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FutureBuilder<List<Topic>>(
              future: topics,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (snapshot.hasData) {
                  return ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Topic topic = snapshot.data![index];
                      return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopicsScreen(
                              parentId: topic.id,
                              title: "${topic.chapter}  ${topic.name}",
                            ),
                          ),
                        );
                      },
                      child: _buildTopicItem(topic),
                    );
                    },
                    separatorBuilder: (context, index) => Divider(),
                  );
                }
                return Column(
                  children: snapshot.data!
                    .map((topic) => _buildTopicItem(topic))
                    .toList(),
                  );
              },
            ),
          ),
          SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to CreateTopicScreen
                    },
                    child: Text("+ Add a new topic"),
                  ),
                ),
              ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Divider(thickness: 2),
                quill.QuillToolbar.simple(
                  configurations: quill.QuillSimpleToolbarConfigurations(
                    controller: _controller,
                    sharedConfigurations: const quill.QuillSharedConfigurations(
                      locale: Locale('de'),
                      )
                    )
                  ),
                  Expanded(
                    child: quill.QuillEditor.basic(
                      // focusNode: _focusNode,
                      configurations: quill.QuillEditorConfigurations(
                        controller: _controller,
                        readOnly: false,
                        autoFocus: true,
                        sharedConfigurations: const quill.QuillSharedConfigurations(
                          locale: Locale('de'),
                      ),
                    ),
                ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[

                      ],
                    )
                  ),
                )
              ],
              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: (){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CreateTopicScreen(parentId: widget.parentId)),
        ).then((_){
          setState(() {
            topics = DatabaseHelper.instance.getTopics(widget.parentId);
          });
        });
      },
      tooltip: 'Add a new course',
      child: Icon(Icons.add), 
      )
    );
  }
}
