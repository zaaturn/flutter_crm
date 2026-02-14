class InfoField {
  final String label;
  final String? value;
  final bool copyable;
  final bool isHighlight;

  const InfoField(
      this.label,
      this.value, {
        this.copyable = false,
        this.isHighlight = false,
      });
}
