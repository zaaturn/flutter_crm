class PostAttachment {
  final int id;
  final String file;
  final String fileType;

  PostAttachment({
    required this.id,
    required this.file,
    required this.fileType,
  });

  factory PostAttachment.fromJson(Map<String, dynamic> json) {
    return PostAttachment(
      id: json['id'],
      file: json['file'],
      fileType: json['file_type'],
    );
  }
}