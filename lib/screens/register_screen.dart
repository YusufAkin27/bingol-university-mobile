import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_media/main.dart';
import 'package:social_media/models/department.dart';
import 'package:social_media/models/grade.dart';
import 'package:social_media/models/faculty.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthDateController = TextEditingController();
  Department? _selectedDepartment;
  Faculty? _selectedFaculty;
  Grade? _selectedGrade;
  bool _gender = true; // true: Erkek, false: Kadın
  int _currentStep = 0;
  bool _obscurePassword = true; // Şifre görünürlüğü için

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://localhost:8080/v1/api/student/sign-up'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'firstName': _nameController.text,
          'lastName': _surnameController.text,
          'username': _usernameController.text,
          'password': _passwordController.text,
          'email': _emailController.text,
          'mobilePhone': _phoneController.text.replaceAll(' ', ''),
          'department': _selectedDepartment?.name,
          'faculty': _selectedFaculty?.name,
          'grade': _selectedGrade?.name,
          'birthDate': _birthDateController.text,
          'gender': _gender,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['isSuccess']) {
          // Giriş sayfasına yönlendir
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // Hata mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        // Hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt başarısız! Lütfen bilgilerinizi kontrol edin.')),
        );
      }
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = "${picked.toLocal()}".split(' ')[0]; // YYYY-MM-DD formatında
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Koyu arka plan
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[850]!],
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
                  color: Colors.grey[900], // Koyu kutu rengi
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
                    children: [
                      SvgPicture.asset(
                        'assets/icons/register.svg',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 20),

                      // Adım Bilgisi
                      Text(
                        'Adım ${_currentStep + 1} / 3',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 20),

                      // Adım 1: Kişisel Bilgiler
                      if (_currentStep == 0) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Ad',
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen adınızı girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _surnameController,
                          decoration: InputDecoration(
                            labelText: 'Soyad',
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen soyadınızı girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: const Icon(Icons.email, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen e-posta adresinizi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          maxLength: 12, // Maksimum 10 karakter
                          decoration: InputDecoration(
                            labelText: 'Telefon Numarası',
                            prefixIcon: const Icon(Icons.phone, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          onChanged: _formatPhoneNumber,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen telefon numaranızı girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _nextStep,
                          child: Text('İleri'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _previousStep,
                          child: Text('Geri', style: TextStyle(color: Colors.blue)),
                        ),
                      ] else if (_currentStep == 1) ...[
                        // Adım 2: Hesap Bilgileri
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen kullanıcı adınızı girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white,
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
                            filled: true,
                            fillColor: Colors.grey[800],
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifrenizi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _nextStep,
                          child: Text('İleri'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _previousStep,
                          child: Text('Geri', style: TextStyle(color: Colors.blue)),
                        ),
                      ] else if (_currentStep == 2) ...[
                        // Adım 3: Eğitim Bilgileri
                        DropdownButtonFormField<Faculty>(
                          value: _selectedFaculty,
                          decoration: InputDecoration(
                            labelText: 'Fakülte',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          items: Faculty.values.map((Faculty faculty) {
                            return DropdownMenuItem<Faculty>(
                              value: faculty,
                              child: Text(faculty.displayName, style: TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFaculty = value;
                              _selectedDepartment = null; // Seçim yapıldığında bölümü sıfırla
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Lütfen fakültenizi seçin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Department>(
                          value: _selectedDepartment,
                          decoration: InputDecoration(
                            labelText: 'Bölüm',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          items: _selectedFaculty?.departments.map((Department department) {
                            return DropdownMenuItem<Department>(
                              value: department,
                              child: Text(department.displayName, style: TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Lütfen bölümünüzü seçin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _birthDateController,
                          decoration: InputDecoration(
                            labelText: 'Doğum Tarihi',
                            prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          readOnly: true,
                          onTap: () => _selectBirthDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen doğum tarihinizi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cinsiyet:'),
                            Row(
                              children: [
                                Radio<bool>(
                                  value: true,
                                  groupValue: _gender,
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value!;
                                    });
                                  },
                                ),
                                const Text('Erkek'),
                                Radio<bool>(
                                  value: false,
                                  groupValue: _gender,
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value!;
                                    });
                                  },
                                ),
                                const Text('Kadın'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _register,
                          child: Text('Kayıt Ol'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text('Giriş Yap', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
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

  void _formatPhoneNumber(String value) {
    // Telefon numarasını formatla
    String formatted = value.replaceAll(' ', '');
    if (formatted.length > 3) {
      formatted = formatted.replaceRange(3, 3, ' ');
    }
    if (formatted.length > 7) {
      formatted = formatted.replaceRange(7, 7, ' ');
    }
    _phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.fromPosition(TextPosition(offset: formatted.length)),
    );
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      _updateFcmToken();
    } else {
      print('User declined or has not accepted permission');
      // Günlük izin isteme işlemi burada yapılabilir
    }
  }

  Future<void> _updateFcmToken() async {
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      // FCM token'ı sunucuya gönder
      await http.put(
        Uri.parse('http://localhost:8080/v1/api/student/updateFcmToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fcmToken': fcmToken}),
      );
    }
  }
}

void main() {
  runApp(MyApp());
  NotificationService().requestNotificationPermission();
} 