import 'package:flutter/material.dart';

class TambahPenggunaForm extends StatefulWidget {
  const TambahPenggunaForm({super.key});

  @override
  State<TambahPenggunaForm> createState() => _TambahPenggunaFormState();
}

class _TambahPenggunaFormState extends State<TambahPenggunaForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedRole;

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
                  ),

                  // 🔹 Email
                  _buildTextField(
                    label: 'Email',
                    hint: 'Masukkan email aktif',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // 🔹 Nomor HP
                  _buildTextField(
                    label: 'Nomor HP',
                    hint: 'Masukkan nomor HP (cth: 08xxxxxxxxxx)',
                    keyboardType: TextInputType.phone,
                  ),

                  // 🔹 Password
                  _buildTextField(
                    label: 'Password',
                    hint: 'Masukkan password',
                    obscureText: true,
                  ),

                  // 🔹 Konfirmasi Password
                  _buildTextField(
                    label: 'Konfirmasi Password',
                    hint: 'Masukkan ulang password',
                    obscureText: true,
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
                    items: const [
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      DropdownMenuItem(
                        value: 'Petugas',
                        child: Text('Petugas'),
                      ),
                      DropdownMenuItem(value: 'Warga', child: Text('Warga')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedRole = value);
                    },
                  ),

                  const SizedBox(height: 28),

                  // 🔹 Tombol Aksi
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data berhasil disimpan!'),
                              ),
                            );
                          }
                        },
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
                        child: const Text('Simpan'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          _formKey.currentState!.reset();
                          setState(() => selectedRole = null);
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
}
