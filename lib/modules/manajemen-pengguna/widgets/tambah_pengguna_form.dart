import 'package:flutter/material.dart';
import 'package:jawarapbl/services/user_management_service.dart';

class TambahPenggunaForm extends StatefulWidget {
  const TambahPenggunaForm({super.key});

  @override
  State<TambahPenggunaForm> createState() => _TambahPenggunaFormState();
}

class _TambahPenggunaFormState extends State<TambahPenggunaForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = UserManagementService();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String? selectedRole;
  bool _isSubmitting = false;

  final List<String> _roleOptions = const [
    'admin', 'rw', 'rt', 'bendahara', 'sekretaris', 'warga'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _nikCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Akun Pengguna',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 🔹 Nama Lengkap
                  _buildTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama wajib diisi'
                        : null,
                  ),

                  // 🔹 Email
                  _buildTextField(
                    label: 'Email',
                    hint: 'Masukkan email aktif',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                      final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                      return ok ? null : 'Format email tidak valid';
                    },
                  ),

                  // 🔹 NIK
                  _buildTextField(
                    label: 'NIK',
                    hint: 'Masukkan NIK (16 digit)',
                    keyboardType: TextInputType.number,
                    controller: _nikCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'NIK wajib diisi';
                      if (v.trim().length != 16) return 'NIK harus 16 digit';
                      return null;
                    },
                  ),

                  // 🔹 Nomor HP
                  _buildTextField(
                    label: 'Nomor HP',
                    hint: 'Masukkan nomor HP',
                    keyboardType: TextInputType.phone,
                    controller: _phoneCtrl,
                  ),

                  // 🔹 Password
                  _buildTextField(
                    label: 'Password',
                    hint: 'Masukkan password',
                    obscureText: true,
                    controller: _passwordCtrl,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Minimal 6 karakter'
                        : null,
                  ),

                  // 🔹 Konfirmasi Password
                  _buildTextField(
                    label: 'Konfirmasi Password',
                    hint: 'Masukkan ulang password',
                    obscureText: true,
                    controller: _confirmPasswordCtrl,
                    validator: (v) => (v != _passwordCtrl.text)
                        ? 'Konfirmasi password tidak cocok'
                        : null,
                  ),

                  // 🔹 Dropdown Role
                  const SizedBox(height: 16),
                  const Text(
                    'Role',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      hintText: '-- Pilih Role --',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    items: _roleOptions
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedRole = value);
                    },
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Role wajib dipilih'
                        : null,
                  ),

                  const SizedBox(height: 28),

                  // 🔹 Tombol Aksi
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          _formKey.currentState!.reset();
                          setState(() => selectedRole = null);
                          _nameCtrl.clear();
                          _emailCtrl.clear();
                          _nikCtrl.clear();
                          _phoneCtrl.clear();
                          _passwordCtrl.clear();
                          _confirmPasswordCtrl.clear();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Widget reusable untuk TextField
  Widget _buildTextField({
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            obscureText: obscureText,
            keyboardType: keyboardType,
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final ok = await _service.createUser(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      nik: _nikCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: selectedRole!,
      status: 'active',
    );

    setState(() => _isSubmitting = false);

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna berhasil ditambahkan')),
        );
        Navigator.of(context).maybePop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan pengguna')),
        );
      }
    }
  }
}
