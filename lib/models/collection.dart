class Collection {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int quoteCount; // Not stored in DB, calculated on fetch

  Collection({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.quoteCount = 0,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      quoteCount: json['quote_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        if (description != null) 'description': description,
      };

  Collection copyWith({
    String? name,
    String? description,
    int? quoteCount,
  }) {
    return Collection(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      quoteCount: quoteCount ?? this.quoteCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Collection && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Collection(id: $id, name: $name, quoteCount: $quoteCount)';
}