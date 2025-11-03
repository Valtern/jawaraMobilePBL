import 'dart:io'; // Import for File
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawarapbl/services/auth_services.dart'; 

class RegisterSection extends StatefulWidget {
  const RegisterSection({super.key});

  @override
  State<RegisterSection> createState() => _RegisterSectionState();
}

class _RegisterSectionState extends State<RegisterSection> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService(); 

  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _jenisKelamin;
  File? _fotoIdentitas;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _fotoIdentitas = File(pickedFile.path);
      });
    }
  }

  // Method to handle registration
  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password tidak cocok!')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      bool success = await _authService.register(
        name: _namaController.text,
        nik: _nikController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        jenisKelamin: _jenisKelamin!,
        fotoIdentitas: _fotoIdentitas,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil! Menunggu persetujuan admin.')),
        );
        Navigator.pop(context); // Go back to login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran gagal. Periksa kembali data Anda.')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _namaController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftar Akun',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Lengkapi formulir untuk membuat akun.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nikController,
                label: 'NIK',
                hint: 'Masukkan NIK sesuai KTP',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController, 
                label: 'Email',
                hint: 'Masukkan email aktif',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController, 
                label: 'No Telepon',
                hint: '08xxxxxxxxxx',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController, 
                label: 'Password',
                hint: 'Masukkan password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _confirmPasswordController, 
                label: 'Konfirmasi Password',
                hint: 'Masukkan ulang password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Jenis Kelamin',
                hint: '-- Pilih Jenis Kelamin --',
                items: ['Laki-laki', 'Perempuan'],
                value: _jenisKelamin, // Add value
                onChanged: (val) { // Add onChanged
                  setState(() {
                    _jenisKelamin = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Pilih Rumah yang Sudah Ada',
                hint: '-- Pilih Rumah --',
                items: ['Rumah A', 'Rumah B'],
                onChanged: (val) {}, // Not implemented in backend yet
                validator: null, 
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Alamat Rumah (Jika Tidak Ada di List)',
                hint: 'Blok 5A / No. 10',
                validator: null, 
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Status kepemilikan rumah',
                hint: '-- Pilih Status --',
                items: ['Milik Sendiri', 'Sewa'],
                onChanged: (val) {}, // Not implemented in backend yet
                validator: null, 
              ),
              const SizedBox(height: 16),
              _buildFileUploadField(label: 'Foto Identitas'),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Buat Akun',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),

              const SizedBox(height: 24),
               Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: <TextSpan>[
                      const TextSpan(text: 'Sudah punya akun? '),
                      TextSpan(
                        text: 'Masuk',
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pop(context);
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? controller, // Add controller
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator, // Make validator optional
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, // Assign controller
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: validator ?? // Use provided validator or default
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Mohon isi kolom ini';
                }
                return null;
              },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
    String? value, // Add value
    void Function(String?)? onChanged, // Add onChanged
    String? Function(String?)? validator, // Make validator optional
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          value: value, // Assign value
          hint: Text(hint),
          onChanged: onChanged, // Assign onChanged
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          validator: validator ?? // Use provided validator or default
              (value) {
                if (value == null) {
                  return 'Mohon pilih salah satu';
                }
                return null;
              },
        ),
      ],
    );
  }

  Widget _buildFileUploadField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: _fotoIdentitas != null 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      _fotoIdentitas!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.grey[600],
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload foto KK/KTP (.png/.jpg)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}