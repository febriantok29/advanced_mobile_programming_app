import 'dart:math';

import 'package:advanced_mobile_programming_app/app/models/user.dart';
import 'package:advanced_mobile_programming_app/app/services/user_service.dart';
import 'package:advanced_mobile_programming_app/app/ui_items/user_bottom_sheet_form.dart';
import 'package:flutter/material.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _service = UserService();
  late Future<List<User>> _usersFuture = _service.getUsers();

  void _refreshUsers() {
    setState(() {
      _usersFuture = _service.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshUsers),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<User>>(
          future: _usersFuture,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(
                'Gagal memuat pengguna: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              );
            }

            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return const Text('Tidak ada pengguna ditemukan.');
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, index) {
                final user = users[index];

                return _buildUserCard(user);
              },
            );
          },
        ),
      ),
      floatingActionButton: _buildAddUserButton(),
    );
  }

  final _random = Random();

  Widget _buildUserCard(User user) {
    final pictureImageURL =
        'https://avatars.githubusercontent.com/u/${_random.nextInt(10000000)}?v=${_random.nextInt(100)}';

    return InkWell(
      onTap: () async {
        bool? needRefresh = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
          useSafeArea: true,
          showDragHandle: true,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          builder: (_) => UserBottomSheetForm(user: user),
        );

        needRefresh ??= false;

        if (needRefresh) {
          _refreshUsers();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(pictureImageURL),
                    radius: 30,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email == null || user.email!.isEmpty
                            ? 'Email tidak tersedia'
                            : user.email!,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: Icon(Icons.person, size: 16),
                          ),
                          Expanded(
                            child: Text(
                              user.gender?.label ?? 'Tidak diketahui',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Konfirmasi Hapus'),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus pengguna ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && user.id != null) {
                      await _service.deleteUser(user.id!);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengguna berhasil dihapus'),
                          ),
                        );
                        _refreshUsers();
                      }
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Ketuk kartu untuk mengedit informasi pengguna.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddUserButton() {
    return FloatingActionButton(
      onPressed: () async {
        bool? needRefresh = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
          useSafeArea: true,
          showDragHandle: true,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          builder: (_) => const UserBottomSheetForm(),
        );

        needRefresh ??= false;

        if (needRefresh) {
          _refreshUsers();
        }
      },
      child: const Icon(Icons.add),
    );
  }
}
