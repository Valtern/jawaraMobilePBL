import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; 
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/shared/models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final _namaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nikController = TextEditingController();

  // Password Controllers
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Warga Controllers
  final _tempatLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  DateTime? _tanggalLahir;
  String? _jenisKelamin;
  String? _agama;
  String? _statusPerkawinan;

  File? _fotoProfil;
  String? _fotoProfilUrl;
  
  bool _isLoading = true;
  bool _isPasswordLoading = false;
  
  // --- BIOMETRIC STATE ---
  int? _userId;
  bool _isFaceLoginEnabled = false;
  bool _isBiometricLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final User? user = await _authService.getProfile();

    if (user != null) {
      _userId = user.id;
      _isFaceLoginEnabled = user.isFaceLoginEnabled; // Load status

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

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    _tempatLahirController.dispose();
    _pekerjaanController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _fotoProfil = File(pickedFile.path);
        _fotoProfilUrl = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tanggalLahir) {
      setState(() => _tanggalLahir = picked);
    }
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? errorMessage = await _authService.updateProfile(
        name: _namaController.text,
        phone: _phoneController.text,
        tempatLahir: _tempatLahirController.text.isNotEmpty ? _tempatLahirController.text : null,
        tanggalLahir: _tanggalLahir,
        jenisKelamin: _jenisKelamin,
        agama: _agama,
        statusPerkawinan: _statusPerkawinan,
        pekerjaan: _pekerjaanController.text.isNotEmpty ? _pekerjaanController.text : null,
        fotoProfil: _fotoProfil,
      );

      setState(() => _isLoading = false);

      if (errorMessage == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!')));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    }
  }

  void _handleChangePassword() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi semua kolom password.')));
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password baru tidak cocok.')));
      return;
    }

    setState(() => _isPasswordLoading = true);

    String? errorMessage = await _authService.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );

    setState(() => _isPasswordLoading = false);

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diperbarui!')));
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  // --- BIOMETRIC ACTIONS ---
  
  void _navigateToEnrollment() {
    if (_userId != null) {
      // Navigate to enrollment and refresh data when coming back
      Navigator.pushNamed(context, '/face-enroll', arguments: _userId)
          .then((_) => _loadProfileData());
    }
  }

  void _disableBiometric() async {
    setState(() => _isBiometricLoading = true);
    
    bool success = await _authService.disableBiometric();
    
    setState(() {
      _isBiometricLoading = false;
      if (success) {
        _isFaceLoginEnabled = false;
      }
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrik berhasil dinonaktifkan.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menonaktifkan biometrik.')));
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
            const Padding(padding: EdgeInsets.only(right: 16.0), child: Center(child: CupertinoActivityIndicator()))
          else
            IconButton(icon: const Icon(CupertinoIcons.check_mark_circled_solid), onPressed: _handleSave),
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
                    _buildAccountInfoCard(), 
                    const SizedBox(height: 16),
                    _buildBiometricCard(), // <--- NEW CARD ADDED HERE
                    const SizedBox(height: 16),
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Simpan Perubahan Profil', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImagePicker() {
    Widget imageContent;
    if (_fotoProfil != null) {
      imageContent = ClipOval(child: Image.file(_fotoProfil!, fit: BoxFit.cover, width: 120, height: 120));
    } else if (_fotoProfilUrl != null) {
      imageContent = ClipOval(
          child: Image.network(_fotoProfilUrl!, fit: BoxFit.cover, width: 120, height: 120,
              errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar()));
    } else {
      imageContent = _buildDefaultAvatar();
    }
    return Stack(children: [
      imageContent,
      Positioned(
          bottom: 0, right: 0,
          child: GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                  child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 20))))
    ]);
  }

  Widget _buildDefaultAvatar() {
    return Container(
        width: 120, height: 120,
        decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
        child: Icon(CupertinoIcons.person_fill, color: Colors.grey[600], size: 80));
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...children
            ])));
  }

  // --- NEW WIDGET FOR BIOMETRICS ---
  Widget _buildBiometricCard() {
    return _buildSectionCard(
      title: 'Keamanan Biometrik',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.face_retouching_natural, color: Colors.deepPurple),
                SizedBox(width: 12),
                Text("Login Wajah", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isFaceLoginEnabled ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isFaceLoginEnabled ? "Aktif" : "Tidak Aktif",
                style: TextStyle(
                  color: _isFaceLoginEnabled ? Colors.green[800] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_isBiometricLoading)
          const Center(child: CircularProgressIndicator())
        else if (!_isFaceLoginEnabled)
          // CASE 1: Not Enabled -> Show "Enable" button
          OutlinedButton.icon(
            onPressed: _navigateToEnrollment,
            icon: const Icon(Icons.add_a_photo),
            label: const Text("Aktifkan Biometrik (Wajah)"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(45),
              foregroundColor: Colors.deepPurple,
              side: const BorderSide(color: Colors.deepPurple),
            ),
          )
        else
          // CASE 2: Enabled -> Show "Retake" and "Disable"
          Column(
            children: [
              OutlinedButton.icon(
                onPressed: _navigateToEnrollment,
                icon: const Icon(Icons.refresh),
                label: const Text("Ambil Ulang Data Wajah"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _disableBiometric,
                icon: const Icon(Icons.no_photography_outlined),
                label: const Text("Nonaktifkan Biometrik"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAccountInfoCard() {
    return _buildSectionCard(
      title: 'Informasi Akun',
      children: [
        _buildTextField(
          controller: _namaController, label: 'Nama Lengkap', hint: 'Masukkan nama lengkap', icon: CupertinoIcons.person_fill,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController, label: 'No Telepon', hint: '08xxxxxxxxxx', icon: CupertinoIcons.phone_fill, keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController, label: 'Email', hint: 'email@example.com', icon: CupertinoIcons.mail_solid, readOnly: true, validator: null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nikController, label: 'NIK', hint: '16-digit NIK', icon: CupertinoIcons.creditcard_fill, readOnly: true, validator: null,
        ),
        const Divider(height: 32),
        const Text('Ubah Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _oldPasswordController, label: 'Password Lama', hint: 'Masukkan password lama', icon: CupertinoIcons.lock_fill, obscureText: true, validator: null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _newPasswordController, label: 'Password Baru', hint: 'Masukkan password baru', icon: CupertinoIcons.lock_fill, obscureText: true, validator: null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController, label: 'Konfirmasi Password Baru', hint: 'Masukkan ulang password baru', icon: CupertinoIcons.lock_fill, obscureText: true, validator: null,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isPasswordLoading ? null : _handleChangePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, foregroundColor: Colors.deepPurple, side: const BorderSide(color: Colors.deepPurple),
            minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isPasswordLoading ? const CircularProgressIndicator() : const Text('Ubah Password', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildSectionCard(
      title: 'Data Diri',
      children: [
        _buildDropdownField(
          label: 'Jenis Kelamin', hint: 'Data tidak ada', icon: CupertinoIcons.person_2_fill,
          items: ['Laki-laki', 'Perempuan'], value: _jenisKelamin,
          onChanged: (val) => setState(() => _jenisKelamin = val), validator: null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _tempatLahirController, label: 'Tempat Lahir', hint: 'Data tidak ada', icon: CupertinoIcons.map_pin_ellipse, validator: null,
        ),
        const SizedBox(height: 16),
        _buildDateField(
          label: 'Tanggal Lahir', hint: 'Data tidak ada', icon: CupertinoIcons.calendar, value: _tanggalLahir,
          onTap: () => _selectDate(context), validator: null,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Agama', hint: 'Data tidak ada', icon: CupertinoIcons.book_fill,
          items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Lainnya'], value: _agama,
          onChanged: (val) => setState(() => _agama = val), validator: null,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Status Perkawinan', hint: 'Data tidak ada', icon: CupertinoIcons.heart_fill,
          items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'], value: _statusPerkawinan,
          onChanged: (val) => setState(() => _statusPerkawinan = val), validator: null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _pekerjaanController, label: 'Pekerjaan', hint: 'Data tidak ada', icon: CupertinoIcons.briefcase_fill, validator: null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label, required String hint, required IconData icon, TextEditingController? controller,
    TextInputType? keyboardType, bool readOnly = false, bool obscureText = false, String? Function(String?)? validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller, keyboardType: keyboardType, readOnly: readOnly, obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint, prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
          filled: readOnly, fillColor: Colors.grey[100], border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        validator: validator ?? (value) { if (validator != null && (value == null || value.isEmpty)) return 'Mohon isi kolom ini'; return null; },
      ),
    ]);
  }

  Widget _buildDropdownField({
    required String label, required String hint, required IconData icon, required List<String> items,
    String? value, void Function(String?)? onChanged, String? Function(String?)? validator
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
          decoration: InputDecoration(border: const OutlineInputBorder(), prefixIcon: Icon(icon, color: Colors.grey[600], size: 20), contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
          initialValue: value, hint: Text(hint), onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
          validator: validator)
    ]);
  }

  Widget _buildDateField({
    required String label, required String hint, required IconData icon, required DateTime? value,
    required VoidCallback onTap, String? Function(String?)? validator
  }) {
    final displayValue = value != null ? DateFormat('dd MMMM yyyy').format(value) : '';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
          readOnly: true, controller: TextEditingController(text: displayValue),
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: Colors.grey[600], size: 20), border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
          onTap: onTap, validator: validator)
    ]);
  }
}