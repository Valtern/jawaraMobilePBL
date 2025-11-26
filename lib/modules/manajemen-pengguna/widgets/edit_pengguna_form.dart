import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; 
import 'package:jawarapbl/modules/manajemen-pengguna/widgets/pengguna_card.dart';
import 'package:jawarapbl/services/user_management_service.dart';
import 'package:jawarapbl/services/auth_services.dart'; // Imported AuthService

class EditPenggunaForm extends StatefulWidget {
  final PenggunaData user;
  const EditPenggunaForm({super.key, required this.user});

  @override
  State<EditPenggunaForm> createState() => _EditPenggunaFormState();
}

class _EditPenggunaFormState extends State<EditPenggunaForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = UserManagementService();
  final _authService = AuthService(); // Initialize AuthService to access URLs
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _nikCtrl;
  late TextEditingController _phoneCtrl;
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _tempatLahirCtrl = TextEditingController();
  final _pekerjaanCtrl = TextEditingController();
  DateTime? _selectedTanggalLahir;

  String? selectedRole;
  String? selectedStatus;
  
  String? selectedGender;
  String? selectedAgama;
  String? selectedKawin;

  File? _selectedImage;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<String> _roleOptions = const ['admin', 'rw', 'rt', 'bendahara', 'sekretaris', 'warga'];
  final List<String> _statusOptions = const ['pending', 'active', 'rejected'];
  final List<String> _genderOptions = const ['Laki-laki', 'Perempuan'];
  final List<String> _agamaOptions = const ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'];
  final List<String> _kawinOptions = const ['Kawin', 'Belum Kawin', 'Cerai Hidup', 'Cerai Mati'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.nama);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _nikCtrl = TextEditingController(text: widget.user.nik ?? '');
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    selectedRole = widget.user.role;
    selectedStatus = widget.user.status;
    
    _fetchFullData();
  }

  Future<void> _fetchFullData() async {
    try {
      final data = await _service.getUser(widget.user.id);
      if (data != null && mounted) {
        if (data['warga'] != null) {
          final warga = data['warga'];
          setState(() {
            _tempatLahirCtrl.text = warga['tempat_lahir'] ?? '';
            _pekerjaanCtrl.text = warga['pekerjaan'] ?? '';
            selectedGender = warga['jenis_kelamin'];
            selectedAgama = warga['agama'];
            selectedKawin = warga['status_perkawinan'];
            if (warga['tanggal_lahir'] != null) {
              _selectedTanggalLahir = DateTime.parse(warga['tanggal_lahir']);
            }
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _nikCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _pekerjaanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggalLahir ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedTanggalLahir = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
                _buildHeader(),
                const SizedBox(height: 24),
                
                const Text("Data Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple)),
                const Divider(),
                const SizedBox(height: 16),
                _buildTextField(label: 'Nama Lengkap', hint: 'Nama Lengkap', controller: _nameCtrl, icon: Icons.person),
                _buildTextField(label: 'Email', hint: 'Email', controller: _emailCtrl, icon: Icons.email, keyboardType: TextInputType.emailAddress),
                _buildTextField(label: 'NIK', hint: 'Nomor Induk Kependudukan', controller: _nikCtrl, icon: Icons.credit_card, keyboardType: TextInputType.number),
                _buildTextField(label: 'Nomor HP', hint: '08...', controller: _phoneCtrl, icon: Icons.phone, keyboardType: TextInputType.phone),

                const SizedBox(height: 16),
                const Text("Data Kependudukan (Warga)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple)),
                const Divider(),
                const SizedBox(height: 16),
                
                _buildTextField(label: 'Tempat Lahir', hint: 'Kota Kelahiran', controller: _tempatLahirCtrl, icon: Icons.location_city),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tanggal Lahir", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _selectedTanggalLahir == null 
                                ? 'Pilih Tanggal' 
                                : DateFormat('yyyy-MM-dd').format(_selectedTanggalLahir!),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildDropdown("Jenis Kelamin", _genderOptions, selectedGender, (v) => setState(() => selectedGender = v), Icons.wc),
                _buildDropdown("Agama", _agamaOptions, selectedAgama, (v) => setState(() => selectedAgama = v), Icons.mosque),
                _buildDropdown("Status Perkawinan", _kawinOptions, selectedKawin, (v) => setState(() => selectedKawin = v), Icons.favorite),
                _buildTextField(label: 'Pekerjaan', hint: 'Pekerjaan saat ini', controller: _pekerjaanCtrl, icon: Icons.work),

                const SizedBox(height: 16),
                const Text("Keamanan & Akses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple)),
                const Divider(),
                const SizedBox(height: 16),
                
                _buildTextField(label: 'Password Baru (Opsional)', hint: 'Isi jika ganti pass', controller: _passwordCtrl, icon: Icons.lock, obscureText: true),
                _buildTextField(label: 'Konfirmasi Password', hint: 'Ulangi password', controller: _confirmPasswordCtrl, icon: Icons.lock, obscureText: true,
                  validator: (v) => (_passwordCtrl.text.isNotEmpty && v != _passwordCtrl.text) ? 'Password tidak cocok' : null
                ),

                Row(
                  children: [
                    Expanded(child: _buildDropdown("Role", _roleOptions, selectedRole, (v) => setState(() => selectedRole = v), Icons.admin_panel_settings)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDropdown("Status", _statusOptions, selectedStatus, (v) => setState(() => selectedStatus = v), Icons.check_circle)),
                  ],
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleUpdate,
                    child: _isSubmitting 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SIMPAN PERUBAHAN'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Batal'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          _buildProfileImagePicker(),
          const SizedBox(height: 12),
          Text(widget.user.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(widget.user.email, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Stack(
      children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.deepPurple.shade100, width: 3),
            image: _selectedImage != null
              ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
              : (widget.user.fotoIdentitas != null
                  ? DecorationImage(
                      image: NetworkImage("${_authService.storageUrl}/${widget.user.fotoIdentitas}"), // FIXED HERE
                      fit: BoxFit.cover
                    )
                  : null),
          ),
          child: (_selectedImage == null && widget.user.fotoIdentitas == null)
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 0, right: 0,
          child: InkWell(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    bool obscureText = false,
    TextInputType? keyboardType,
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
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, void Function(String?) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true, // Prevents overflow
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
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
      fotoIdentitas: _selectedImage,
      
      tempatLahir: _tempatLahirCtrl.text.trim(),
      tanggalLahir: _selectedTanggalLahir != null ? DateFormat('yyyy-MM-dd').format(_selectedTanggalLahir!) : null,
      jenisKelamin: selectedGender,
      agama: selectedAgama,
      statusPerkawinan: selectedKawin,
      pekerjaan: _pekerjaanCtrl.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perubahan disimpan')));
      Navigator.of(context).maybePop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan perubahan')));
    }
  }
}