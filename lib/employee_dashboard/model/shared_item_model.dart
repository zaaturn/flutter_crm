class SharedItemModel {
  final String id;
  final String title;
  final String description;
  final String sharedBy;
  final DateTime sharedAt;
  final String? iconType;

  SharedItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sharedBy,
    required this.sharedAt,
    this.iconType,
  });

  factory SharedItemModel.fromMap(Map<String, dynamic> m) {
    return SharedItemModel(
      id: m['id']?.toString() ?? '',
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      sharedBy: m['shared_by'] ?? 'Admin',
      sharedAt: m['shared_at'] != null ? DateTime.parse(m['shared_at']).toLocal() : DateTime.now(),
      iconType: m['icon_type'],
    );
  }
}
