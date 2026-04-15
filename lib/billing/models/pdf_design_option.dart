class PdfDesignOption {
  /// Backend enum id, e.g. `"MINIMAL" | "CLASSIC" | "MODERN"`
  final String id;
  final String label;
  final String? description;

  const PdfDesignOption({
    required this.id,
    required this.label,
    this.description,
  });

  factory PdfDesignOption.fromJson(Map<String, dynamic> json) {
    return PdfDesignOption(
      id: json["id"]?.toString() ?? "",
      label: json["label"]?.toString() ?? "",
      description: json["description"]?.toString(),
    );
  }

  @override
  String toString() => label.isNotEmpty ? label : id;
}

