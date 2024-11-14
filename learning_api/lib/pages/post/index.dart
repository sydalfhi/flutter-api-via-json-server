// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:learning_api/models/post.dart';
import 'package:learning_api/pages/post/form.dart';
import 'package:learning_api/services/post_service.dart';

/// Layar untuk menampilkan daftar posting
class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  // Layanan untuk menangani operasi posting
  final PostService _postService = PostService();

  // Daftar posting yang akan ditampilkan
  List<Post> _posts = [];

  // Status loading untuk menampilkan indikator loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Ambil posting saat widget pertama kali dibuat
    _fetchPosts();
  }

  /// Mengambil daftar posting dari layanan
  Future<void> _fetchPosts() async {
    try {
      // Mendapatkan posting dari layanan
      final posts = await _postService.getPosts();

      // Perbarui state dengan posting yang diambil
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      // Atur status loading menjadi false jika terjadi kesalahan
      setState(() {
        _isLoading = false;
      });

      // Tampilkan pesan kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat posting: $e')),
      );
    }
  }

  /// Navigasi ke layar pembuatan/edit posting
  Future<void> _navigateToCreatePost({Post? post}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(existingPost: post),
      ),
    );

    // Refresh daftar jika ada perubahan
    if (result == true) {
      _fetchPosts();
    }
  }

  /// Menghapus posting
  Future<void> _deletePost(Post post) async {
    try {
      // Konfirmasi penghapusan
      bool? confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus posting ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      // Lanjutkan penghapusan jika dikonfirmasi
      if (confirmDelete == true) {
        await _postService.deletePost(post.id!);

        // Perbarui state setelah menghapus
        setState(() {
          _posts.remove(post);
        });

        // Tampilkan pesan berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posting berhasil dihapus')),
        );
      }
    } catch (e) {
      // Tampilkan pesan kesalahan jika gagal menghapus
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus posting: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar dengan judul 'Posting'
      appBar: AppBar(
        title: const Text('Posting'),
        // Tambahkan tombol refresh di app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPosts,
          ),
        ],
      ),

      // Tampilan body
      body: _isLoading
          // Tampilkan indikator loading jika sedang memuat
          ? const Center(child: const CircularProgressIndicator())
          // Tampilkan daftar posting jika sudah selesai memuat
          : RefreshIndicator(
              onRefresh: _fetchPosts,
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return ListTile(
                    // Tampilkan judul posting
                    title: Text(post.title ?? ''),
                    // Tampilkan penulis posting
                    subtitle: Text(post.author ?? ''),
                    // Tambahkan trailing actions untuk edit dan delete
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol edit
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToCreatePost(post: post),
                        ),
                        // Tombol hapus
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deletePost(post),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

      // Tombol mengambang untuk menambah posting baru
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke layar pembuatan posting baru
          _navigateToCreatePost();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
