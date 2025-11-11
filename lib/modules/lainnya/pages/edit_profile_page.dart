import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Add 'intl' to your pubspec.yaml for date formatting
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/shared/models/user_model.dart';
// Note: We are also editing fields from the 'Warga' model,
// so controllers for them are included here.

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // Controllers for User model fields
  final _namaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nikController = TextEditingController();

  // --- NEW PASSWORD CONTROLLERS ---
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers for Warga model fields
  final _tempatLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  DateTime? _tanggalLahir;
  String? _jenisKelamin;
  String? _agama;
  String? _statusPerkawinan;

  File? _fotoProfil;
  String? _fotoProfilUrl;
  bool _isLoading = true;
  bool _isPasswordLoading = false; // For the new button

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // ... (This function is unchanged from the previous step)
    setState(() {
      _isLoading = true;
    });

    final User? user = await _authService.getProfile();

    if (user != null) {
      _namaController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email;
      _nikController.text = user.nik ?? '';

      if (user.fotoIdentitas != null) {
        _fotoProfilUrl = '${_authService.storageUrl}/${user.fotoIdentitas}';
      }

      _tempatLahirController.text = user.tempatLahir ?? '';
      _pekerjaanController.text = user.pekerjaan ?? '';
      _jenisKelamin = user.jenisKelamin;
      _agama = user.agama;
      _statusPerkawinan = user.statusPerkawinan;

      if (user.tanggalLahir != null && user.tanggalLahir!.isNotEmpty) {
        try {
          _tanggalLahir = DateTime.parse(user.tanggalLahir!);
        } catch (e) {
          _tanggalLahir = null;
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    _tempatLahirController.dispose();
    _pekerjaanController.dispose();

    // --- DISPOSE NEW CONTROLLERS ---
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    // ... (This function is unchanged)
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _fotoProfil = File(pickedFile.path);
        _fotoProfilUrl = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // ... (This function is unchanged)
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tanggalLahir) {
      setState(() {
        _tanggalLahir = picked;
      });
    }
  }

  // This is the "Simpan Perubahan" button logic (unchanged)
  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? errorMessage = await _authService.updateProfile(
        name: _namaController.text,
        phone: _phoneController.text,
        tempatLahir: _tempatLahirController.text.isNotEmpty
            ? _tempatLahirController.text
            : null,
        tanggalLahir: _tanggalLahir,
        jenisKelamin: _jenisKelamin,
        agama: _agama,
        statusPerkawinan: _statusPerkawinan,
        pekerjaan: _pekerjaanController.text.isNotEmpty
            ? _pekerjaanController.text
            : null,
        fotoProfil: _fotoProfil,
      );

      setState(() {
        _isLoading = false;
      });

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  // --- NEW FUNCTION for the "Ubah Password" button ---
  void _handleChangePassword() async {
    // Basic validation
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua kolom password.')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru tidak cocok.')),
      );
      return;
    }

    setState(() {
      _isPasswordLoading = true;
    });

    String? errorMessage = await _authService.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );

    setState(() {
      _isPasswordLoading = false;
    });

    if (errorMessage == null) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diperbarui!')),
      );
      // Clear fields
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    } else {
      // Failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Ubah Profil'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CupertinoActivityIndicator()),
            )
          else
            IconButton(
              icon: const Icon(CupertinoIcons.check_mark_circled_solid),
              onPressed: _handleSave,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImagePicker(),
                    const SizedBox(height: 24),
                    _buildAccountInfoCard(), // This card is now updated
                    const SizedBox(height: 16),
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 16),
                    // _buildSecurityCard() is REMOVED
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan Profil', // Text updated for clarity
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- Omitted: _buildProfileImagePicker, _buildDefaultAvatar, _buildSectionCard ---
  // --- (They are unchanged) ---
  Widget _buildProfileImagePicker() {
    Widget imageContent;
    if (_fotoProfil != null) {
      imageContent = ClipOval(
          child: Image.file(_fotoProfil!,
              fit: BoxFit.cover, width: 120, height: 120));
    } else if (_fotoProfilUrl != null) {
      imageContent = ClipOval(
          child: Image.network(_fotoProfilUrl!,
              fit: BoxFit.cover,
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) =>
                  _buildDefaultAvatar()));
    } else {
      imageContent = _buildDefaultAvatar();
    }
    return Stack(children: [
      imageContent,
      Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.deepPurple, shape: BoxShape.circle),
                  child: const Icon(CupertinoIcons.camera_fill,
                      color: Colors.white, size: 20))))
    ]);
  }

  Widget _buildDefaultAvatar() {
    return Container(
        width: 120,
        height: 120,
        decoration:
            BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
        child:
            Icon(CupertinoIcons.person_fill, color: Colors.grey[600], size: 80));
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...children
                ])));
  }

  // --- MODIFIED FUNCTION ---
  // This now contains the password fields and button
  Widget _buildAccountInfoCard() {
    return _buildSectionCard(
      title: 'Informasi Akun',
      children: [
        _buildTextField(
          controller: _namaController,
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap',
          icon: CupertinoIcons.person_fill,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'No Telepon',
          hint: '08xxxxxxxxxx',
          icon: CupertinoIcons.phone_fill,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'email@example.com',
          icon: CupertinoIcons.mail_solid,
          readOnly: true,
          validator: null, // No validation for read-only
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nikController,
          label: 'NIK',
          hint: '16-digit NIK',
          icon: CupertinoIcons.creditcard_fill,
          readOnly: true,
          validator: null, // No validation for read-only
        ),

        // --- NEW PASSWORD SECTION ---
        const Divider(height: 32),
        const Text(
          'Ubah Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _oldPasswordController,
          label: 'Password Lama',
          hint: 'Masukkan password lama',
          icon: CupertinoIcons.lock_fill,
          obscureText: true,
          validator: null, // Optional
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _newPasswordController,
          label: 'Password Baru',
          hint: 'Masukkan password baru',
          icon: CupertinoIcons.lock_fill,
          obscureText: true,
          validator: null, // Optional
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Konfirmasi Password Baru',
          hint: 'Masukkan ulang password baru',
          icon: CupertinoIcons.lock_fill,
          obscureText: true,
          validator: null, // Optional
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isPasswordLoading ? null : _handleChangePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Different color
            foregroundColor: Colors.deepPurple, // Text color
            side: const BorderSide(color: Colors.deepPurple), // Border
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isPasswordLoading
              ? const CircularProgressIndicator()
              : const Text(
                  'Ubah Password',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ],
    );
  }

  // --- Omitted: _buildPersonalInfoCard ---
  // --- (This is unchanged from the previous step) ---
  Widget _buildPersonalInfoCard() {
    return _buildSectionCard(
      title: 'Data Diri',
      children: [
        _buildDropdownField(
          label: 'Jenis Kelamin',
          hint: 'Data tidak ada',
          icon: CupertinoIcons.person_2_fill,
          items: ['Laki-laki', 'Perempuan'],
          value: _jenisKelamin,
          onChanged: (val) {
            setState(() {
              _jenisKelamin = val;
            });
          },
          validator: null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _tempatLahirController,
          label: 'Tempat Lahir',
          hint: 'Data tidak ada',
          icon: CupertinoIcons.map_pin_ellipse,
          validator: null,
        ),
        const SizedBox(height: 16),
        _buildDateField(
          label: 'Tanggal Lahir',
          hint: 'Data tidak ada',
          icon: CupertinoIcons.calendar,
          value: _tanggalLahir,
          onTap: () => _selectDate(context),
          validator: null,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Agama',
          hint: 'Data tidak ada',
          icon: CupertinoIcons.book_fill,
          items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Lainnya'],
          value: _agama,
          onChanged: (val) {
            setState(() {
              _agama = val;
            });
          },
          validator: null,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Status Perkawinan',
          hint: 'Data tidak ada',
          icon: CupertinoIcons.heart_fill,
          items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'],
          value: _statusPerkawinan,
          onChanged: (val) {
            setState(() {
              _statusPerkawinan = val;
            });
          },
          validator: null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _pekerjaanController,
          label: 'Pekerjaan',
          hint: 'Data tidak ada',
          icon: CupertinoIcons.briefcase_fill,
          validator: null,
        ),
      ],
    );
  }

  // --- _buildSecurityCard() is REMOVED ---

  // --- MODIFIED FUNCTION ---
  // Added obscureText parameter
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool obscureText = false, // ADDED
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          obscureText: obscureText, // ADDED
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            filled: readOnly,
            fillColor: Colors.grey[100],
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          validator: validator ??
              (value) {
                // Default validator only runs if validator is NOT null
                if (validator != null && (value == null || value.isEmpty)) {
                  return 'Mohon isi kolom ini';
                }
                return null;
              },
        ),
      ],
    );
  }

  // --- Omitted: _buildDropdownField, _buildDateField ---
  // --- (They are unchanged) ---
  Widget _buildDropdownField(
      {required String label,
      required String hint,
      required IconData icon,
      required List<String> items,
      String? value,
      void Function(String?)? onChanged,
      String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
          initialValue: value,
          hint: Text(hint),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          validator: validator)
    ]);
  }

  Widget _buildDateField(
      {required String label,
      required String hint,
      required IconData icon,
      required DateTime? value,
      required VoidCallback onTap,
      String? Function(String?)? validator}) {
    final displayValue =
        value != null ? DateFormat('dd MMMM yyyy').format(value) : '';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
          readOnly: true,
          controller: TextEditingController(text: displayValue),
          decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
          onTap: onTap,
          validator: validator)
    ]);
  }
}