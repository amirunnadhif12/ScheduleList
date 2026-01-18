import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/user_session.dart';
import 'dashboard.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isLogin = true;
  bool isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _toggleView() {
    setState(() {
      isLogin = !isLogin;
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    });
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password tidak boleh kosong!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final userName = result['user']['name'] ?? '';
        final userId = result['user']['id'];
        final userEmail = result['user']['email'] ?? '';
        
        // Save user session
        UserSession().login(
          userId: userId,
          userName: userName,
          userEmail: userEmail,
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userName: userName,
              userId: userId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login gagal')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi!')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password harus minimal 6 karakter!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );

        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
        setState(() => isLogin = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Pendaftaran gagal')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon/logo_schedule.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.calendar_today_rounded,
                          size: 80,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Schedule-List',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola jadwal dan tugas kuliah Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.text.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTab('Masuk', Icons.login, isLogin),
                      _buildTab('Daftar', Icons.person_add_outlined, !isLogin),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                if (!isLogin) ...[
                  _buildLabel('Nama Lengkap'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Nama lengkap Anda',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                ],

                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  hint: 'nama@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),
                _buildLabel('Password'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: true,
                ),

                if (!isLogin) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Minimal 6 karakter',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.text.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : (isLogin ? _login : _register),
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isLogin ? Icons.login : Icons.person_add,
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(
                      isLoading
                          ? 'Memproses...'
                          : (isLogin ? 'Masuk' : 'Daftar Sekarang'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      disabledBackgroundColor:
                          AppColors.primary.withOpacity(0.6),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                      style: TextStyle(
                        color: AppColors.text.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleView,
                      child: Text(
                        isLogin ? 'Daftar di sini' : 'Masuk',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, bool active) {
    return GestureDetector(
      onTap: () {
        if (!active) _toggleView();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? AppColors.text : AppColors.text.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active
                    ? AppColors.text
                    : AppColors.text.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.text.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: AppColors.text.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
