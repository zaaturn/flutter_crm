class Project {
  final String id;
  final String title;
  final String status;
  final String deadline;
  final String owner;

  const Project({
    required this.id,
    required this.title,
    required this.status,
    required this.deadline,
    required this.owner,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      deadline: json['deadline'] ?? '',
      owner: json['owner'] ?? '',
    );
  }
}
