import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _message = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String username = _emailController.text;
    final String password = _passwordController.text;

    // IP adresi ve cihaz bilgisi otomatik alınacak
    String ipAddress = 'otomatik_alınan_ip'; // Buraya gerçek IP adresi eklenmeli
    String deviceInfo = 'otomatik_alınan_cihaz_bilgisi'; // Buraya gerçek cihaz bilgisi eklenmeli

    final response = await http.post(
      Uri.parse('http://localhost:8080/v1/api/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'password': password,
        'ipAddress': ipAddress,
        'deviceInfo': deviceInfo,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String accessToken = data['accessToken'];
      String refreshToken = data['refreshToken'];

      // Token'ları SharedPreferences içinde sakla
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);

      setState(() {
        _message = 'Giriş başarılı!';
      });

      // Ana sayfaya yönlendirme
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _message = 'Giriş başarısız! Lütfen bilgilerinizi kontrol edin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
       child: SafeArea(
  child: Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white, // Change the background color to white
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
                child: Form(
                 key: _formKey,
child: Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // Logo (Giriş Efekti ile)
   AnimatedOpacity(
  opacity: 1.0,
  duration: Duration(seconds: 1),
  child: ClipOval(
    child: Image.asset(
      'assets/images/logo.png',
      height: 100,
      width: 100, // Ensure width and height are the same to make it a perfect circle
      fit: BoxFit.cover, // Optional: Adjusts the image to cover the circle
    ),
  ),
),
const SizedBox(height: 20),


    // Hoş Geldiniz Metni
    const Text(
      'Hoş Geldiniz',
      style: TextStyle(
        fontSize: 32, // Daha büyük ve dikkat çekici font
        fontWeight: FontWeight.w700, // Daha güçlü bir vurgu
        color: Colors.white,
        letterSpacing: 1.2, // Daha şık bir aralık
        shadows: [
          Shadow(
            color: Colors.black54,
            offset: Offset(2, 2), // Hafif gölge efekti
            blurRadius: 4,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    ),

    const SizedBox(height: 10),

    // Kısa Açıklama
    const Text(
      'Devam etmek için giriş yapın veya kayıt olun.',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white70, // Hafif soluk, göz yormayan renk
      ),
      textAlign: TextAlign.center,
    ),

    const SizedBox(height: 30),
  
  



                      // E-posta Alanı
                     TextFormField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    labelText: 'Kullanıcı Adı',
    prefixIcon: const Icon(
      CupertinoIcons.person,
      color: Colors.grey, // Soft gray icon color
    ),
    filled: true,
    fillColor: Colors.white, // White background for input field
    labelStyle: TextStyle(
      color: Colors.grey.shade700, // Soft dark gray label color
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none, // No border by default
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.blueAccent.shade400, // Blue border when focused
        width: 2,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.grey.shade300, // Light gray border when enabled
        width: 1,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.redAccent, // Red border on error
        width: 2,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.red, // More prominent red on focused error
        width: 2.5,
      ),
    ),
    errorStyle: TextStyle(
      color: Colors.redAccent.shade100, // Soft red color for error message
      fontWeight: FontWeight.bold,
    ),
  ),
  style: TextStyle(
    color: Colors.black, // Dark text for readability
    fontSize: 18,
    letterSpacing: 1.1, // Slightly increased letter spacing
  ),
  cursorColor: Colors.blueAccent.shade400, // Blue cursor for focus
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen kullanıcı adınızı girin';
    }
    return null;
  },
),
const SizedBox(height: 16),



                      // Şifre Alanı
  TextFormField(
  controller: _passwordController,
  obscureText: !_isPasswordVisible,
  decoration: InputDecoration(
    labelText: 'Şifre',
    prefixIcon: const Icon(
      CupertinoIcons.lock,
      color: Colors.grey, // Lighter gray for the icon
    ),
    filled: true,
    fillColor: Colors.white, // White background for the input field
    labelStyle: TextStyle(
      color: Colors.grey.shade700, // Slightly darker gray for the label
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    suffixIcon: AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: IconButton(
        key: ValueKey<bool>(_isPasswordVisible),
        icon: Icon(
          _isPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
          color: Colors.grey, // Light gray for the eye icon
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15), // Rounded corners for a smooth look
      borderSide: BorderSide.none, // No border by default
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.blueAccent.shade200, // Soft blue border when focused
        width: 2,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.grey.shade400, // Subtle gray border when enabled
        width: 1,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.redAccent, // Red border for errors
        width: 2,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: Colors.red, // Darker red for focused error
        width: 2.5,
      ),
    ),
    errorStyle: TextStyle(
      color: Colors.redAccent.shade100, // Soft red for error message
      fontWeight: FontWeight.bold,
    ),
  ),
  cursorColor: Colors.blueAccent.shade200, // Blue cursor for better focus visibility
  style: TextStyle(
    color: Colors.black, // Black text for strong contrast
    fontSize: 18, // Slightly larger text for readability
    letterSpacing: 1.1, // Slight letter spacing for a neat look
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen şifrenizi girin';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  },
),


                      // Şifremi Unuttum
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: const Text(
                              'Şifremi Unuttum',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                      // Giriş Yap Butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Giriş Yap',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kayıt Ol yönlendirmesi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Hesabınız yok mu?', style: TextStyle(color: Colors.white)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),
                      Text(
                        _message,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}