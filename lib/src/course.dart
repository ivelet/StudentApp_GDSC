class Course {
  final int id;
  final String name;
  final int credits;
  // final DateTime startDate;
  // final DataTime endDate;

  Course({required this.id, required this.name, required this.credits});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'credits': credits,
    };
  }

  // Optionally, create a method to convert a database map to a Course object
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
      credits: map['credits'],
    );
  }
}
