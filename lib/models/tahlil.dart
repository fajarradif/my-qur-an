class Tahlil {
  final int id;
  final String title;
  final String arabic;
  final String latin;
  final String translation;

  Tahlil({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
  });

  factory Tahlil.fromJson(Map<String, dynamic> json) {
    return Tahlil(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      arabic: json['arabic'] ?? '',
      latin: json['latin'] ?? '',
      translation: json['translation'] ?? '',
    );
  }
}
