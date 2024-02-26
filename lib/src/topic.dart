class Topic {
  final int id;
  final String name;
  final int courseId;
  final int parentId;
  final String chapter;
  final int ranking;
  final String notes;
  final String material;

  Topic({required this.id, required this.name, required this.parentId, required this.courseId, required this.chapter, required this.ranking, required this.notes, required this.material});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'course_id': courseId,
      'parent_id': parentId,
      'chapter': chapter,
      'ranking': ranking,
      'notes': notes,
      'material': material
    };
  }

  // Optionally, create a method to convert a database map to a Course object
  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      name: map['name'],
      courseId: map['courseId'],
      parentId: map['parentId'],
      chapter: map['chapter'],
      ranking: map['ranking'],
      notes: map['notes'],
      material: map['material']
    );
  }
}
