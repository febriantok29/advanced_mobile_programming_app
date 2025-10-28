import 'package:advanced_mobile_programming_app/app/models/user.dart';
import 'package:advanced_mobile_programming_app/app/services/user_service.dart';
import 'package:flutter/material.dart';

class UserBottomSheetForm extends StatefulWidget {
  final User? user;
  final UserService? service;

  const UserBottomSheetForm({super.key, this.user, this.service});

  @override
  State<UserBottomSheetForm> createState() => _UserBottomSheetFormState();
}

class _UserBottomSheetFormState extends State<UserBottomSheetForm> {
  late final _service = widget.service ?? UserService();

  final _form = GlobalKey<FormState>();
  late final _user = widget.user ?? User();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  Gender? _selectedGender;

  void _listener() {
    setState(() {
      _user.firstName = _firstNameController.text;
      _user.lastName = _lastNameController.text;
      _user.email = _emailController.text;
    });
  }

  void _selectGender(Gender value) {
    setState(() {
      _selectedGender = value;
      _user.gender = value;
    });
  }

  void _resetForm() {
    setState(() {
      _user.reset();
      _selectedGender = null;
      _firstNameController.text = '';
      _lastNameController.text = '';
      _emailController.text = '';
    });

    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    if (widget.user != null) {
      _firstNameController.text = widget.user?.firstName ?? '';
      _lastNameController.text = widget.user?.lastName ?? '';
      _emailController.text = widget.user?.email ?? '';
      _selectedGender = widget.user?.gender;
    }

    // Add listeners after initializing values
    _firstNameController.addListener(_listener);
    _lastNameController.addListener(_listener);
    _emailController.addListener(_listener);

    // Ensure proper text selection by setting selection after text is set
    _setTextSelectionToEnd(_firstNameController);
    _setTextSelectionToEnd(_lastNameController);
    _setTextSelectionToEnd(_emailController);
  }

  // Helper method to ensure proper text selection
  void _setTextSelectionToEnd(TextEditingController controller) {
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_listener);
    _lastNameController.removeListener(_listener);
    _emailController.removeListener(_listener);

    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 24.0,
            ),
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _buildForms(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildForms() {
    return [
      // Title with close button
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.user == null ? 'Tambah User Baru' : 'Edit User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // First Name
      TextFormField(
        controller: _firstNameController,
        focusNode: _firstNameFocusNode,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Nama Depan',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person),
        ),
        enableInteractiveSelection: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Nama depan tidak boleh kosong';
          }

          return null;
        },
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_lastNameFocusNode);
        },
      ),
      const SizedBox(height: 16),

      // Last Name
      TextFormField(
        controller: _lastNameController,
        focusNode: _lastNameFocusNode,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Nama Belakang',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person_outline),
        ),
        enableInteractiveSelection: true,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_emailFocusNode);
        },
      ),
      const SizedBox(height: 16),

      // Email
      TextFormField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.email),
        ),
        keyboardType: TextInputType.emailAddress,
        enableInteractiveSelection: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) {
            return 'Format email tidak valid';
          }

          return null;
        },
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
      const SizedBox(height: 16),

      // Gender selection
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jenis Kelamin', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: Gender.values
                  .map(
                    (gender) => ChoiceChip(
                      label: Text(gender.label),
                      selected:
                          _selectedGender == gender || _user.gender == gender,
                      onSelected: (selected) {
                        if (selected) {
                          _selectGender(gender);
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // Action Buttons
      Row(
        children: [
          if (widget.user != null)
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                onPressed: _resetForm,
              ),
            ),
          if (widget.user != null) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                if (_form.currentState?.validate() ?? false) {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Simpan data user?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  );

                  confirm ??= false;

                  if (!confirm || !mounted) {
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const AlertDialog(
                      content: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16.0),
                            Text('Menyimpan data user...'),
                          ],
                        ),
                      ),
                    ),
                  );

                  try {
                    _user.validate();

                    if (widget.user == null) {
                      await _service.addUser(_user);
                    } else if (_user.id != null) {
                      await _service.updateUser(_user);
                    } else {
                      throw Exception('ID user tidak ditemukan untuk update.');
                    }

                    if (!mounted) {
                      return;
                    }

                    Navigator.of(context).pop();

                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Sukses'),
                        content: const Text('Data user berhasil disimpan.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );

                    if (!mounted) {
                      return;
                    }

                    Navigator.of(context).pop(true);
                  } catch (e) {
                    if (!mounted) {
                      return;
                    }

                    Navigator.of(context).pop();

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Gagal'),
                        content: Text(
                          'Gagal menyimpan data user. ${e.toString()}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              label: const Text('Simpan Data User'),
            ),
          ),
        ],
      ),
    ];
  }
}
