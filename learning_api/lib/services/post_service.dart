import 'package:http/http.dart' as http;
import 'package:learning_api/models/post.dart';
import 'dart:convert';

/// Kelas untuk menangani operasi API terkait Post
class PostService {
  // URL dasar untuk API Post
  final String baseUrl = 'http://10.0.2.2:5000/posts'; // local or with emulator
  // final String baseUrl =
  // 'http://localhost:5000/posts'; // local or with emulator
  // Untuk iOS simulator: 'http://localhost:5000/posts'

  // Untuk device fisik: gunakan IP komputer anda, misal 'http://IP:5000/posts'

  /// Mengambil semua post dari server
  ///
  /// Mengembalikan daftar objek [Post]
  /// Melemparkan [Exception] jika permintaan API gagal
  Future<List<Post>> getPosts() async {
    try {
      // Mengirim permintaan GET untuk mengambil semua post
      final response = await http.get(Uri.parse(baseUrl));

      // Memeriksa apakah permintaan berhasil
      if (response.statusCode == 200) {
        // Menguraikan respons JSON menjadi daftar objek Post
        List<dynamic> body = json.decode(response.body);
        List<Post> posts =
            body.map((dynamic item) => Post.fromJson(item)).toList();
        return posts;
      } else {
        // Melemparkan exception jika permintaan gagal
        throw Exception(
            'Gagal memuat post. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      // Menangani kesalahan jaringan atau penguraian
      throw Exception('Kesalahan saat mengambil post: $e');
    }
  }

  /// Membuat post baru di server
  ///
  /// [post] adalah objek [Post] yang akan dibuat
  /// Mengembalikan [Post] yang telah dibuat dengan ID yang ditetapkan oleh server
  /// Melemparkan [Exception] jika pembuatan post gagal
  Future<Post> createPost(Post post) async {
    try {
      // Mengirim permintaan POST untuk membuat post baru
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(post.toJson()),
      );

      // Memeriksa apakah post berhasil dibuat
      if (response.statusCode == 201) {
        // Menguraikan dan mengembalikan post yang telah dibuat
        return Post.fromJson(json.decode(response.body));
      } else {
        // Melemparkan exception jika pembuatan post gagal
        throw Exception(
            'Gagal membuat post. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      // Menangani kesalahan jaringan atau penguraian
      throw Exception('Kesalahan saat membuat post: $e');
    }
  }

  /// Memperbarui post yang ada di server
  ///
  /// [post] adalah objek [Post] yang akan diperbarui
  /// Mengembalikan [Post] yang telah diperbarui
  /// Melemparkan [Exception] jika pembaruan post gagal
  Future<Post> updatePost(Post post) async {
    // Memeriksa bahwa post memiliki ID
    if (post.id == null) {
      throw ArgumentError('Post harus memiliki ID untuk diperbarui');
    }

    try {
      // Mengirim permintaan PUT untuk memperbarui post yang ada
      final response = await http.put(
        Uri.parse('$baseUrl/${post.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(post.toJson()),
      );

      // Memeriksa apakah post berhasil diperbarui
      if (response.statusCode == 200) {
        // Menguraikan dan mengembalikan post yang telah diperbarui
        return Post.fromJson(json.decode(response.body));
      } else {
        // Melemparkan exception jika pembaruan post gagal
        throw Exception(
            'Gagal memperbarui post. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      // Menangani kesalahan jaringan atau penguraian
      throw Exception('Kesalahan saat memperbarui post: $e');
    }
  }

  /// Menghapus post dari server
  ///
  /// [id] adalah ID post yang akan dihapus
  /// Melemparkan [Exception] jika penghapusan post gagal
  Future<void> deletePost(String id) async {
    // Memeriksa bahwa ID tidak kosong
    if (id.isEmpty) {
      throw ArgumentError('ID post tidak boleh kosong');
    }

    try {
      // Mengirim permintaan DELETE untuk menghapus post
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      // Memeriksa apakah post berhasil dihapus
      if (response.statusCode != 200) {
        // Melemparkan exception jika penghapusan gagal
        throw Exception(
            'Gagal menghapus post. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      // Menangani kesalahan jaringan atau penguraian
      throw Exception('Kesalahan saat menghapus post: $e');
    }
  }
}
