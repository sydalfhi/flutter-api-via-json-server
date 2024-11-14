// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:learning_api/models/post.dart';
import 'package:learning_api/services/post_service.dart';

/// Layar untuk membuat atau mengedit posting
class CreatePostScreen extends StatefulWidget {
  // Parameter opsional untuk edit posting
  final Post? existingPost;

  const CreatePostScreen({super.key, this.existingPost});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  // Kontroller untuk input teks
  late TextEditingController _titleController;
  late TextEditingController _authorController;

  // Layanan untuk menangani operasi posting
  final PostService _postService = PostService();

  // Status mode (create atau edit)
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();

    // Tentukan mode berdasarkan ada tidaknya posting yang diteruskan
    _isEditMode = widget.existingPost != null;

    // Inisialisasi kontroller dengan nilai awal
    _titleController = TextEditingController(
      text: _isEditMode ? widget.existingPost!.title : '',
    );
    _authorController = TextEditingController(
      text: _isEditMode ? widget.existingPost!.author : '',
    );
  }

  @override
  void dispose() {
    // Hapus kontroller untuk mencegah memory leak
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  /// Fungsi untuk menyimpan posting (membuat atau memperbarui)
  Future<void> _savePost() async {
    try {
      // Validasi input
      if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Judul dan penulis tidak boleh kosong')),
        );
        return;
      }

      // Buat objek posting
      final post = Post(
        id: _isEditMode ? widget.existingPost!.id : null,
        title: _titleController.text,
        author: _authorController.text,
      );

      // Proses posting berdasarkan mode
      if (_isEditMode) {
        // Update posting yang ada
        await _postService.updatePost(post);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posting berhasil diperbarui')),
        );
      } else {
        // Buat posting baru
        await _postService.createPost(post);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posting berhasil dibuat')),
        );
      }

      // Kembali ke layar sebelumnya
      Navigator.of(context).pop(true);
    } catch (e) {
      // Tampilkan pesan kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan posting: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul dinamis berdasarkan mode
        title: Text(_isEditMode ? 'Edit Posting' : 'Buat Posting Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input untuk judul
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Posting',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Input untuk penulis
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Penulis',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Tombol untuk menyimpan
            ElevatedButton(
              onPressed: _savePost,
              child: Text(_isEditMode ? 'Perbarui' : 'Buat'),
            ),
          ],
        ),
      ),
    );
  }
}
