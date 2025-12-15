import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/shared/models/user_model.dart';
import 'package:jawarapbl/modules/auth/pages/ktp_camera_page.dart';

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
  bool _isScanningKTP = false;

  // Biometric State
  int? _userId;
  bool _isFaceLoginEnabled = false;
  bool _isBiometricLoading = false;
  String? _userRole;

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
      _isFaceLoginEnabled = user.isFaceLoginEnabled;
      _userRole = user.role;

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
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _fotoProfil = File(pickedFile.path);
        _fotoProfilUrl = null;
      });
    }
  }

  Future<void> _pickKtpAndScan() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto KTP (Kamera)'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KtpCameraPage(),
                  ),
                );
                if (result != null && result is File) {
                  _performOCR(result);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) {
                  _performOCR(File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
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
      if (result['nik'] != null) {
        _nikController.text = result['nik'];
      }
      if (result['name'] != null) {
        _namaController.text = result['name'];
      }
      if (result['gender'] != null) {
        String gender = result['gender'];
        if (['Laki-laki', 'Perempuan'].contains(gender)) {
          setState(() => _jenisKelamin = gender);
        }
      }

      if (result['face_image'] != null) {
        try {
          Uint8List bytes = base64Decode(result['face_image']);
          final tempDir = await getTemporaryDirectory();
          File file = await File(
            '${tempDir.path}/profile_from_ktp_update.jpg',
          ).create();
          file.writeAsBytesSync(bytes);

          setState(() {
            _fotoProfil = file;
            _fotoProfilUrl = null;
          });
        } catch (e) {
          debugPrint("Error decoding face image: $e");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data berhasil diisi dari KTP! Silakan periksa kembali.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membaca KTP. Pastikan gambar jelas.'),
        ),
      );
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
        email: _emailController.text,
        nik: _nikController.text,
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

      setState(() => _isLoading = false);

      if (errorMessage == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    }
  }

  void _handleChangePassword() async {
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

    setState(() => _isPasswordLoading = true);

    String? errorMessage = await _authService.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );

    setState(() => _isPasswordLoading = false);

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diperbarui!')),
      );
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  void _navigateToEnrollment() {
    if (_userId != null) {
      Navigator.pushNamed(
        context,
        '/face-enroll',
        arguments: _userId,
      ).then((_) => _loadProfileData());
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometrik berhasil dinonaktifkan.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menonaktifkan biometrik.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header with curved background and profile picture in center
          _buildHeaderWithCurve(),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6938EF),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildAccountInfoCard(),
                          const SizedBox(height: 16),
                          _buildBiometricCard(),
                          const SizedBox(height: 16),
                          _buildPersonalInfoCard(),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6938EF),
                              minimumSize: const Size(double.infinity, 56),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Simpan Perubahan Profil',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithCurve() {
    return ClipPath(
      clipper: CurveClipper(),
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Rumah.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Back button and title at top - positioned higher to avoid overlap
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const Expanded(
                          child: Text(
                            'Ubah Profil',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!_isLoading)
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.check_mark_circled_solid,
                              color: Colors.white,
                            ),
                            onPressed: _handleSave,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        else
                          const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
              ),
              // Profile picture and role in center - positioned lower to avoid overlap with title
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate responsive padding based on screen height
                    final screenHeight = MediaQuery.of(context).size.height;
                    // More padding for smaller screens to avoid overlap
                    final topPadding = screenHeight < 700 ? 75.0 : 85.0;

                    return Padding(
                      padding: EdgeInsets.only(top: topPadding),
                      child: Center(child: _buildProfileImageInHeader()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageInHeader() {
    Widget imageContent;
    if (_fotoProfil != null) {
      imageContent = ClipOval(
        child: Image.file(
          _fotoProfil!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      );
    } else if (_fotoProfilUrl != null) {
      imageContent = ClipOval(
        child: Image.network(
          _fotoProfilUrl!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        ),
      );
    } else {
      imageContent = _buildDefaultAvatar();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Profile Picture with camera button
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: imageContent,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6938EF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.camera_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Role
        if (_userRole != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6938EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _userRole!.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        CupertinoIcons.person_fill,
        color: Colors.grey[600],
        size: 60,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricCard() {
    return _buildSectionCard(
      title: 'Keamanan Biometrik',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.face_retouching_natural, color: Color(0xFF6938EF)),
                SizedBox(width: 12),
                Text(
                  "Login Wajah",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    _isFaceLoginEnabled ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isFaceLoginEnabled ? "Aktif" : "Tidak Aktif",
                style: TextStyle(
                  color: _isFaceLoginEnabled
                      ? Colors.green[800]
                      : Colors.grey[600],
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
          OutlinedButton.icon(
            onPressed: _navigateToEnrollment,
            icon: const Icon(Icons.add_a_photo),
            label: const Text("Aktifkan Biometrik (Wajah)"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(45),
              foregroundColor: const Color(0xFF6938EF),
              side: const BorderSide(color: Color(0xFF6938EF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else
          Column(
            children: [
              OutlinedButton.icon(
                onPressed: _navigateToEnrollment,
                icon: const Icon(Icons.refresh),
                label: const Text("Ambil Ulang Data Wajah"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  foregroundColor: const Color(0xFF6938EF),
                  side: const BorderSide(color: Color(0xFF6938EF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
        OutlinedButton.icon(
          onPressed: _pickKtpAndScan,
          icon: const Icon(Icons.document_scanner),
          label: const Text("Scan KTP (Isi Data Otomatis)"),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(45),
            foregroundColor: Colors.blue[700],
            side: BorderSide(color: Colors.blue[700]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_isScanningKTP)
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: LinearProgressIndicator(),
          ),
        const SizedBox(height: 16),
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
          readOnly: false,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nikController,
          label: 'NIK',
          hint: '16-digit NIK',
          icon: CupertinoIcons.creditcard_fill,
          readOnly: false,
          keyboardType: TextInputType.number,
        ),
        const Divider(height: 32),
        const Text(
          'Ubah Password',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _oldPasswordController,
          label: 'Password Lama',
          hint: 'Masukkan password lama',
          icon: CupertinoIcons.lock_fill,
          obscureText: true,
          validator: null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _newPasswordController,
          label: 'Password Baru',
          hint: 'Masukkan password baru',
          icon: CupertinoIcons.lock_fill,
          obscureText: true,
          validator: null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Konfirmasi Password Baru',
          hint: 'Masukkan ulang password baru',
          icon: CupertinoIcons.lock_fill,
          obscureText: true,
          validator: null,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isPasswordLoading ? null : _handleChangePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF6938EF),
            side: const BorderSide(color: Color(0xFF6938EF)),
            minimumSize: const Size(double.infinity, 56),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isPasswordLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6938EF)),
                )
              : const Text(
                  'Ubah Password',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

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
          onChanged: (val) => setState(() => _jenisKelamin = val),
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
          onChanged: (val) => setState(() => _agama = val),
          validator: null,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Status Perkawinan',
          hint: 'Data tidak ada',
          icon: CupertinoIcons.heart_fill,
          items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'],
          value: _statusPerkawinan,
          onChanged: (val) => setState(() => _statusPerkawinan = val),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF6938EF), size: 20),
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
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
          validator: validator ??
              (value) {
                if (validator != null && (value == null || value.isEmpty))
                  return 'Mohon isi kolom ini';
                return null;
              },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    String? value,
    void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
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
            prefixIcon: Icon(icon, color: const Color(0xFF6938EF), size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6938EF)),
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF2D3436),
          ),
          initialValue: value,
          hint: Text(
            hint,
            style: TextStyle(fontFamily: 'Poppins', color: Colors.grey[600]),
          ),
          onChanged: onChanged,
          items: items
              .map<DropdownMenuItem<String>>(
                (String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String hint,
    required IconData icon,
    required DateTime? value,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    final displayValue =
        value != null ? DateFormat('dd MMMM yyyy').format(value) : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(text: displayValue),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF6938EF), size: 20),
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
          onTap: onTap,
          validator: validator,
        ),
      ],
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final curveHeight = 40.0;

    // Start from top-left corner
    path.moveTo(0, 0);
    // Line to top-right corner
    path.lineTo(size.width, 0);
    // Line to bottom-right (before curve)
    path.lineTo(size.width, size.height - curveHeight);
    // Create smooth curve at the bottom
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10,
      0,
      size.height - curveHeight,
    );
    // Close path back to start
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
