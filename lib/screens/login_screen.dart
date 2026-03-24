import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

/// Login screen for user authentication
/// Supports both Women and Police login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('Attempting login with email: ${_emailController.text.trim()}');
    
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser!;
      print('Login successful! User: ${user.name}, Role: ${user.role}');
      
      // Navigate to appropriate dashboard
      if (user.role == UserRole.woman) {
        Navigator.pushReplacementNamed(context, '/women-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/police-dashboard');
      }
    } else {
      print('Login failed for email: ${_emailController.text.trim()}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password. Check console for details.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final role = args?['role'] ?? 'woman';

    return Scaffold(
      appBar: AppBar(
        title: Text('Login as ${role == 'woman' ? 'Woman' : 'Police'}'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Icon
                  Icon(
                    role == 'woman' ? Icons.person : Icons.local_police,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 40),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Login Button
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Divider with OR
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Google Sign-In Button
                  OutlinedButton.icon(
                    onPressed: authProvider.isLoading ? null : () async {
                      final success = await authProvider.signInWithGoogle(
                        role == 'woman' ? UserRole.woman : UserRole.police,
                      );
                      
                      if (!mounted) return;
                      
                      if (success) {
                        final user = authProvider.currentUser!;
                        print('Google Sign-In successful! Navigating to dashboard...');
                        
                        if (user.role == UserRole.woman) {
                          Navigator.pushReplacementNamed(context, '/women-dashboard');
                        } else {
                          Navigator.pushReplacementNamed(context, '/police-dashboard');
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Google Sign-In failed. Please try again.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 32),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Register Link
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/register',
                        arguments: {'role': role},
                      );
                    },
                    child: const Text('Don\'t have an account? Register'),
                  ),
                  
                  // Demo Credentials
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Demo Credentials:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (role == 'woman') ...[
                          const Text('Email: priya@demo.com'),
                          const Text('Password: demo123'),
                        ] else ...[
                          const Text('Email: police@demo.com'),
                          const Text('Password: police123'),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
