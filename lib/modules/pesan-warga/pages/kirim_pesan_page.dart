import 'package:flutter/material.dart';
import 'package:jawarapbl/services/pesan_service.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/modules/pesan-warga/models/user_penerima_model.dart';

class KirimPesanPage extends StatefulWidget {
  const KirimPesanPage({super.key});

  @override
  State<KirimPesanPage> createState() => _KirimPesanPageState();
}

class _KirimPesanPageState extends State<KirimPesanPage> {
  final _formKey = GlobalKey<FormState>();
  final _pesanService = PesanService();

  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  String _selectedRole = 'Semua';
  int? _selectedUser;
  List<UserPenerima> _usersList = [];

  bool _isLoadingUsers = true;
  bool _isSending = false;

  bool _showAspirasiToggle = false;
  bool _kirimSebagaiAspirasi = false;

  final List<String> _roles = [
    'Semua',
    'admin',
    'rw',
    'rt',
    'bendahara',
    'sekretaris',
    'warga',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _usersList = [];
      _selectedUser = null;
      _showAspirasiToggle = false;
      _kirimSebagaiAspirasi = false;
    });

    try {
      final users = await _pesanService.getUsers(role: _selectedRole);
      setState(() {
        _usersList = users;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  void _handleRecipientChanged(int? value) {
    if (value == null) {
      setState(() {
        _selectedUser = null;
        _showAspirasiToggle = false;
        _kirimSebagaiAspirasi = false;
      });
      return;
    }

    final selectedUser = _usersList.firstWhere((user) => user.id == value);
    final role = selectedUser.role;

    final bool showToggle = ['admin', 'rw', 'rt'].contains(role);

    setState(() {
      _selectedUser = value;
      _showAspirasiToggle = showToggle;
      if (!showToggle) {
        _kirimSebagaiAspirasi = false;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_judulController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi pesan tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      String successMessage = '';

      if (_kirimSebagaiAspirasi) {
        await _pesanService.kirimAspirasi(
          judul: _judulController.text,
          isi: _isiController.text,
        );
        successMessage = 'Aspirasi berhasil dikirim.';
      } else {
        if (_selectedUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan pilih penerima pesan terlebih dahulu.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSending = false;
          });
          return;
        }

        await _pesanService.kirimPesan(
          penerimaId: _selectedUser!,
          judul: _judulController.text,
          isi: _isiController.text,
        );
        successMessage = 'Pesan berhasil dikirim.';
      }

      // Handle hasil sukses
      _judulController.clear();
      _isiController.clear();
      setState(() {
        _selectedUser = null;
        _showAspirasiToggle = false;
        _kirimSebagaiAspirasi = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> roleMenuItems = _roles.map((role) {
      return DropdownMenuItem<String>(
        value: role,
        child: Text(role),
      );
    }).toList();

    final List<DropdownMenuItem<int>> userMenuItems = _usersList.map((user) {
      return DropdownMenuItem<int>(
        value: user.id,
        child: Text('${user.namaLengkap} (${user.role})'),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectInput<String>(
              label: 'Filter Role Penerima',
              value: _selectedRole,
              items: roleMenuItems,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                  _fetchUsers();
                }
              },
            ),
            const SizedBox(height: 16),
            _isLoadingUsers
                ? const Center(child: CircularProgressIndicator())
                : SelectInput<int>(
                    label: 'Pilih Penerima',
                    value: _selectedUser,
                    items: userMenuItems,
                    onChanged: _handleRecipientChanged,
                  ),
            const SizedBox(height: 16),
            TextInput(
              controller: _judulController,
              label: 'Judul',
            ),
            const SizedBox(height: 16),
            TextInput(
              controller: _isiController,
              label: 'Isi Pesan / Deskripsi Aspirasi',
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            if (_showAspirasiToggle)
              CheckboxListTile(
                title: const Text('Kirim sebagai Aspirasi'),
                subtitle: const Text(
                    'Akan dikirim ke kotak aspirasi publik, bukan pesan pribadi.'),
                value: _kirimSebagaiAspirasi,
                onChanged: (newValue) {
                  setState(() {
                    _kirimSebagaiAspirasi = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 16),
            _isSending
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: const Text('Kirim'),
                  ),
          ],
        ),
      ),
    );
  }
}