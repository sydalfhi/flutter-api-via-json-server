class Post {
  String? id;
  String? title;
  String? author;

  Post({this.id, this.title, this.author});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    author = json['author'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['author'] = author;
    return data;
  }
}
