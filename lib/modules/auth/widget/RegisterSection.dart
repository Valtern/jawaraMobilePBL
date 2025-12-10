import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  bool _isScanningKTP = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchRumahOptions();
  }

  Future<void> _fetchRumahOptions() async {
    final data = await _dataWargaRumahService.getRumahOptions();
    if (mounted) setState(() => _rumahList = data);
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
        final picked = await _picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          File image = File(picked.path);
          setState(() => _fotoKtp = image);
          _performOCR(image);
        }
      },
      onCamera: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KtpCameraPage()),
        );
        if (result != null && result is File) {
          setState(() => _fotoKtp = result);
          _performOCR(result);
        }
      },
    );
  }

  Future<void> _performOCR(File image) async {
    setState(() => _isScanningKTP = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memindai KTP... Mohon tunggu')),
    );

    final result = await _authService.scanKTP(image);

    setState(() => _isScanningKTP = false);

    if (result != null) {
      if (result['nik'] != null) _nikController.text = result['nik'];
      if (result['name'] != null) _namaController.text = result['name'];
      if (result['gender'] != null)
        setState(() => _jenisKelamin = result['gender']);

      if (result['face_image'] != null) {
        try {
          Uint8List bytes = base64Decode(result['face_image']);
          final tempDir = await getTemporaryDirectory();
          File file = await File(
            '${tempDir.path}/profile_from_ktp.jpg',
          ).create();
          file.writeAsBytesSync(bytes);
          setState(() {
            _fotoProfil = file; // Set the decoded face as profile picture
          });
        } catch (e) {
          debugPrint("Error decoding face image: $e");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data KTP berhasil dipindai!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membaca KTP. Silakan isi manual.')),
      );
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Password tidak cocok!')));
        return;
      }

      setState(() => _isLoading = true);

      String? finalAlamat = _alamatController.text.isNotEmpty
          ? _alamatController.text
          : null;
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
                'Apakah anda ingin mendaftarkan wajah untuk login cepat?',
              ),
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
                      Navigator.pushReplacementNamed(
                        context,
                        '/face-enroll',
                        arguments: userId,
                      );
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
              content: Text(
                result['message'] ?? 'Terjadi kesalahan tidak diketahui',
              ),
            ),
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
              const SizedBox(height: 8),
              _buildModernTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outlined,
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: _nikController,
                label: 'NIK',
                hint: 'Masukkan NIK sesuai KTP',
                keyboardType: TextInputType.number,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Masukkan email aktif',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: _phoneController,
                label: 'No Telepon',
                hint: '08xxxxxxxxxx',
                keyboardType: TextInputType.phone,
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Masukkan password',
                obscureText: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Mohon isi kolom ini';
                  if (v.length < 4) return 'Password minimal 4 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Password',
                hint: 'Masukkan ulang password',
                obscureText: _obscureConfirmPassword,
                onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Mohon isi kolom ini';
                  if (v != _passwordController.text)
                    return 'Password tidak sama';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildModernDropdownField<String>(
                label: 'Jenis Kelamin',
                hint: '-- Pilih Jenis Kelamin --',
                items: ['Laki-laki', 'Perempuan']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                value: _jenisKelamin,
                onChanged: (val) => setState(() => _jenisKelamin = val),
              ),
              const SizedBox(height: 20),
              _buildModernDropdownField<int>(
                label: 'Pilih Rumah yang Sudah Ada',
                hint: _rumahList.isEmpty
                    ? 'Memuat data...'
                    : '-- Pilih Rumah --',
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
                        icon: const Icon(Icons.clear, color: Color(0xFF6938EF)),
                        onPressed: () {
                          setState(() => _selectedRumahId = null);
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  '--- ATAU ---',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildModernTextField(
                controller: _alamatController,
                label: 'Masukkan Alamat Baru (Jika tidak ada di list)',
                hint: 'Blok 5A / No. 10',
                icon: Icons.home_outlined,
                onChanged: (val) {
                  if (val.isNotEmpty && _selectedRumahId != null) {
                    setState(() => _selectedRumahId = null);
                  }
                },
                suffixIcon: _alamatController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF6938EF)),
                        onPressed: () {
                          setState(() {
                            _alamatController.clear();
                          });
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              _buildModernDropdownField<String>(
                label: 'Status kepemilikan rumah',
                hint: '-- Pilih Status --',
                items: ['Milik Sendiri', 'Sewa', 'Kos', 'Kontrak']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                value: _statusKepemilikan,
                onChanged: (val) => setState(() => _statusKepemilikan = val),
                validator: (val) => null,
              ),
              const SizedBox(height: 20),
              _buildFileUploadField(
                label: 'Foto Profil (Opsional)',
                file: _fotoProfil,
                onTap: _pickProfileImage,
                hint: 'Upload foto profil (.png/.jpg)',
              ),
              const SizedBox(height: 20),
              _buildFileUploadField(
                label: 'Foto Identitas (KTP/KK) (Opsional)',
                file: _fotoKtp,
                onTap: _pickKtpImage,
                hint: 'Upload foto KTP/KK (.png/.jpg)',
              ),
              if (_isScanningKTP)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6938EF),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6938EF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Buat Akun',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF2D3436),
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: 'Sudah punya akun? '),
                      TextSpan(
                        text: 'Masuk',
                        style: const TextStyle(
                          color: Color(0xFF6938EF),
                          fontWeight: FontWeight.w600,
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

  Widget _buildModernTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF6938EF)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6938EF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          validator:
              validator ??
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

  Widget _buildModernDropdownField<T>({
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
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontFamily: 'Poppins', color: Colors.grey[600]),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6938EF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            suffixIcon: suffixIcon,
          ),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6938EF)),
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF2D3436),
          ),
          onChanged: onChanged,
          items: items,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(
              Icons.lock_outlined,
              color: Color(0xFF6938EF),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF6938EF),
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6938EF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          validator:
              validator ??
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

  Widget _buildFileUploadField({
    required String label,
    required File? file,
    required VoidCallback onTap,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(file, fit: BoxFit.cover),
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
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
