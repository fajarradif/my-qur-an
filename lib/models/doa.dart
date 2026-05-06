class Doa {
  final String id;
  final String judul;
  final String doa;
  final String latin;
  final String artinya;

  Doa({
    required this.id,
    required this.judul,
    required this.doa,
    required this.latin,
    required this.artinya,
  });

  factory Doa.fromJson(Map<String, dynamic> json) {
    return Doa(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      doa: json['doa'] ?? '',
      latin: json['latin'] ?? '',
      artinya: json['artinya'] ?? '',
    );
  }
}
