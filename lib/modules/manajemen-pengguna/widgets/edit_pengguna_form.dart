import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/widgets/pengguna_card.dart';
import 'package:jawarapbl/services/user_management_service.dart';

class EditPenggunaForm extends StatefulWidget {
  final PenggunaData user;
  const EditPenggunaForm({super.key, required this.user});

  @override
  State<EditPenggunaForm> createState() => _EditPenggunaFormState();
}

class _EditPenggunaFormState extends State<EditPenggunaForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = UserManagementService();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _nikCtrl;
  late TextEditingController _phoneCtrl;
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String? selectedRole;
  String? selectedStatus;
  bool _isSubmitting = false;

  final List<String> _roleOptions = const [
    'admin', 'rw', 'rt', 'bendahara', 'sekretaris', 'warga'
  ];
  final List<String> _statusOptions = const ['pending', 'active', 'rejected'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.nama);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _nikCtrl = TextEditingController(text: widget.user.nik ?? '');
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    selectedRole = widget.user.role;
    selectedStatus = widget.user.status;
  }

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
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Akun Pengguna',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  controller: _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),

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

                _buildTextField(
                  label: 'NIK',
                  hint: 'Biarkan kosong jika tidak diubah',
                  keyboardType: TextInputType.number,
                  controller: _nikCtrl,
                ),

                _buildTextField(
                  label: 'Nomor HP',
                  hint: 'Biarkan kosong jika tidak diubah',
                  keyboardType: TextInputType.phone,
                  controller: _phoneCtrl,
                ),

                _buildTextField(
                  label: 'Password (opsional)',
                  hint: 'Isi hanya jika ingin mengganti',
                  obscureText: true,
                  controller: _passwordCtrl,
                ),

                _buildTextField(
                  label: 'Konfirmasi Password',
                  hint: 'Cocokkan dengan password',
                  obscureText: true,
                  controller: _confirmPasswordCtrl,
                  validator: (v) {
                    if (_passwordCtrl.text.isEmpty) return null;
                    return v == _passwordCtrl.text ? null : 'Konfirmasi tidak cocok';
                  },
                ),

                const SizedBox(height: 16),
                const Text('Role', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  items: _roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setState(() => selectedRole = v),
                  validator: (v) => (v == null || v.isEmpty) ? 'Role wajib dipilih' : null,
                ),

                const SizedBox(height: 16),
                const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => selectedStatus = v),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleUpdate,
                      child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Batal'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            obscureText: obscureText,
            keyboardType: keyboardType,
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final ok = await _service.updateUser(
      id: widget.user.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      nik: _nikCtrl.text.trim().isEmpty ? null : _nikCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      password: _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
      role: selectedRole,
      status: selectedStatus,
    );

    setState(() => _isSubmitting = false);

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perubahan disimpan')));
        Navigator.of(context).maybePop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan perubahan')));
      }
    }
  }
}
