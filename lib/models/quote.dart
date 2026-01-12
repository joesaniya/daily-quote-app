class Quote {
  final String text;
  final String author;
  final String id;

  Quote({
    required this.text,
    required this.author,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
        'id': id,
      };

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] ?? json['q'] ?? '',
      author: json['author'] ?? json['a'] ?? 'Unknown',
      id: json['id'] ??
          json['_id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
