import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/services/dataWargaRumah_service.dart';
import 'package:jawarapbl/modules/auth/pages/ktp_camera_page.dart';

class RegisterSection extends StatefulWidget {
  const RegisterSection({super.key});

  @override
  State<RegisterSection> createState() => _RegisterSectionState();
}

class _RegisterSectionState extends State<RegisterSection> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _dataWargaRumahService = DataWargaRumahService();

  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _alamatController = TextEditingController();

  String? _jenisKelamin;
  int? _selectedRumahId;
  String? _statusKepemilikan;

  List<dynamic> _rumahList = [];

  File? _fotoKtp;
  File? _fotoProfil;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchRumahOptions();
  }

  Future<void> _fetchRumahOptions() async {
    final data = await _dataWargaRumahService.getRumahOptions();
    if (mounted) {
      setState(() {
        _rumahList = data;
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _showPickerOptions({
    required VoidCallback onGallery,
    required VoidCallback onCamera,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                onGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                onCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    await _showPickerOptions(
      onGallery: () async {
        try {
          final picked = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 70,
            maxWidth: 1024,
          );
          if (picked != null) {
            setState(() => _fotoProfil = File(picked.path));
          }
        } catch (e) {
          debugPrint("Gallery error: $e");
        }
      },
      onCamera: () async {
        try {
          final picked = await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 70,
            maxWidth: 1024,
          );
          if (picked != null) {
            setState(() => _fotoProfil = File(picked.path));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kamera tidak tersedia')),
          );
        }
      },
    );
  }

  Future<void> _pickKtpImage() async {
    await _showPickerOptions(
      onGallery: () async {
        try {
          final picked = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 90,
            maxWidth: 2048,
          );
          if (picked != null) {
            setState(() => _fotoKtp = File(picked.path));
          }
        } catch (e) {
          debugPrint("Gallery error: $e");
        }
      },
      onCamera: () async {
        try {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KtpCameraPage()),
          );
          if (result != null && result is File) {
            setState(() => _fotoKtp = result);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal membuka kamera custom")),
          );
        }
      },
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password tidak cocok!')),
        );
        return;
      }

      setState(() => _isLoading = true);

      String? finalAlamat =
          _alamatController.text.isNotEmpty ? _alamatController.text : null;
      int? finalRumahId = (finalAlamat == null) ? _selectedRumahId : null;

      final result = await _authService.register(
        name: _namaController.text,
        nik: _nikController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        jenisKelamin: _jenisKelamin!,
        rumahId: finalRumahId,
        alamat: finalAlamat,
        fotoProfil: _fotoProfil,
        fotoKtp: _fotoKtp,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (result['success'] == true) {
          final userId = result['userId'];

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Registrasi Berhasil'),
              content: const Text(
                  'Apakah anda ingin mendaftarkan wajah untuk login cepat?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text('Nanti Saja'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (userId != null) {
                      Navigator.pushReplacementNamed(context, '/face-enroll',
                          arguments: userId);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ya, Daftar Wajah'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result['message'] ?? 'Terjadi kesalahan tidak diketahui')),
          );
        }
      }
    }
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
                obscureText: _obscurePassword,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Mohon isi kolom ini';
                  if (v.length < 4) return 'Password minimal 4 karakter';
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Password',
                hint: 'Masukkan ulang password',
                obscureText: _obscureConfirmPassword,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Mohon isi kolom ini';
                  if (v != _passwordController.text) return 'Password tidak sama';
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdownField<String>(
                label: 'Jenis Kelamin',
                hint: '-- Pilih Jenis Kelamin --',
                items: ['Laki-laki', 'Perempuan']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                value: _jenisKelamin,
                onChanged: (val) => setState(() => _jenisKelamin = val),
              ),
              const SizedBox(height: 16),
              _buildDropdownField<int>(
                label: 'Pilih Rumah yang Sudah Ada',
                hint:
                    _rumahList.isEmpty ? 'Memuat data...' : '-- Pilih Rumah --',
                items: _rumahList.map<DropdownMenuItem<int>>((item) {
                  return DropdownMenuItem<int>(
                    value: item['id'],
                    child: Text(item['alamat'] ?? 'Rumah #${item['id']}'),
                  );
                }).toList(),
                value: _selectedRumahId,
                onChanged: (val) {
                  setState(() {
                    _selectedRumahId = val;
                    if (val != null) {
                      _alamatController.clear();
                    }
                  });
                },
                validator: (val) => null,
                suffixIcon: _selectedRumahId != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() => _selectedRumahId = null);
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              const Center(
                  child: Text('--- ATAU ---',
                      style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _alamatController,
                label: 'Masukkan Alamat Baru (Jika tidak ada di list)',
                hint: 'Blok 5A / No. 10',
                validator: (val) => null,
                onChanged: (val) {
                  if (val.isNotEmpty && _selectedRumahId != null) {
                    setState(() => _selectedRumahId = null);
                  }
                },
                suffixIcon: _alamatController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _alamatController.clear();
                          });
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField<String>(
                label: 'Status kepemilikan rumah',
                hint: '-- Pilih Status --',
                items: ['Milik Sendiri', 'Sewa', 'Kos', 'Kontrak']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                value: _statusKepemilikan,
                onChanged: (val) => setState(() => _statusKepemilikan = val),
                validator: (val) => null,
              ),
              const SizedBox(height: 16),
              _buildFileUploadField(
                label: 'Foto Profil (Opsional)',
                file: _fotoProfil,
                onTap: _pickProfileImage,
                hint: 'Upload foto profil (.png/.jpg)',
              ),
              const SizedBox(height: 16),
              _buildFileUploadField(
                label: 'Foto Identitas (KTP/KK) (Opsional)',
                file: _fotoKtp,
                onTap: _pickKtpImage,
                hint: 'Upload foto KTP/KK (.png/.jpg)',
              ),
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
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    IconData? icon,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: validator ??
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

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    T? value,
    void Function(T?)? onChanged,
    String? Function(T?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            suffixIcon: suffixIcon,
          ),
          value: value,
          hint: Text(hint),
          onChanged: onChanged,
          items: items,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildFileUploadField({
    required String label,
    required File? file,
    required VoidCallback onTap,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
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
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      file,
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
                        hint,
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