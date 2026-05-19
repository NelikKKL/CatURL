class UrlEntry {
  final String id;
  final String name;
  final String url;
  final String filePath;
  final DateTime createdAt;

  const UrlEntry({
    required this.id,
    required this.name,
    required this.url,
    required this.filePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UrlEntry.fromJson(Map<String, dynamic> json) => UrlEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        filePath: json['filePath'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  UrlEntry copyWith({
    String? id,
    String? name,
    String? url,
    String? filePath,
    DateTime? createdAt,
  }) =>
      UrlEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        url: url ?? this.url,
        filePath: filePath ?? this.filePath,
        createdAt: createdAt ?? this.createdAt,
      );
}
