class Blog {
  final String id;
  final String title;
  final String content;
  final String author;
  final String? authorName;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    this.authorName,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] is Map ? json['author']['_id'] : (json['author'] ?? ''),
      authorName: json['author'] is Map ? json['author']['username'] : null,
    );
  }
}