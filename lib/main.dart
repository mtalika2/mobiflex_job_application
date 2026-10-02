import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MobiFlexJobApplication());
}

class MobiFlexJobApplication extends StatelessWidget {
  const MobiFlexJobApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobiFlex African',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFEAF3FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            side: const BorderSide(
              color: Colors.yellow,
              width: 2,
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
        ),
      ),
      home: const ApplicantLoginPage(),
    );
  }
}

class ApplicantLoginPage extends StatefulWidget {
  const ApplicantLoginPage({super.key});

  @override
  State<ApplicantLoginPage> createState() => _ApplicantLoginPageState();
}

class _ApplicantLoginPageState extends State<ApplicantLoginPage> {
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) {
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      if (kIsWeb) {
        final GoogleAuthProvider provider = GoogleAuthProvider();

        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance
            .authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const JobApplicationPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Google sign-in failed. Please try again.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.work_outline, size: 64),
                    const SizedBox(height: 20),
                    const Text(
                      'MobiFlex African',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Online Job Application',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Apply for Manager, Agent, or Sales Representative (SR).',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSigningIn ? null : _signInWithGoogle,
                        icon: _isSigningIn
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(
                          _isSigningIn
                              ? 'Signing in...'
                              : 'Continue with Google',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Google account is used to securely identify '
                      'your job application.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class JobApplicationPage extends StatefulWidget {
  const JobApplicationPage({super.key});

  @override
  State<JobApplicationPage> createState() => _JobApplicationPageState();
}

class _JobApplicationPageState extends State<JobApplicationPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _schoolController = TextEditingController();
  final _fieldOfStudyController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _selectedPosition;
  String? _selectedQualification;
  String? _selectedGender;

  bool _agreedToTerms = false;
  bool _isSubmitting = false;


  final Map<String, PlatformFile?> _selectedDocuments = {
    'cv': null,
    'qualification': null,
    'nationalId': null,
    'photo': null,
  };

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _schoolController.dispose();
    _fieldOfStudyController.dispose();
    _graduationYearController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );

    if (selectedDate == null) {
      return;
    }

    final String month = selectedDate.month.toString().padLeft(2, '0');
    final String day = selectedDate.day.toString().padLeft(2, '0');

    _dateOfBirthController.text = '${selectedDate.year}-$month-$day';
  }

  static const String _backendUrl = 'http://localhost:3000';

  String _contentTypeForFile(PlatformFile file) {
    final String extension = file.extension?.toLowerCase() ?? '';

    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        throw Exception('Unsupported file type: .$extension');
    }
  }

  Future<void> _uploadDocument(
    String applicationId,
    String documentType,
    PlatformFile file,
  ) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Your Google account session has expired.');
    }

    final String? idToken = await user.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Unable to obtain your authentication token.');
    }

    final Uint8List bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception(
        'Unable to read ${file.name}. Please select the file again.',
      );
    }

    final String contentType = _contentTypeForFile(file);
    final List<String> parts = contentType.split('/');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$_backendUrl/job-applications/$applicationId/documents',
      ),
    );

    request.headers['Authorization'] = 'Bearer $idToken';

    request.fields['documentType'] = documentType;

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
        contentType: MediaType(parts[0], parts[1]),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    Map<String, dynamic> responseBody = {};

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        responseBody = decoded;
      }
    } catch (_) {}

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        responseBody['message']?.toString() ??
            'Unable to upload ${file.name}.',
      );
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPosition == null) {
      _showMessage('Please select the position you are applying for.');
      return;
    }

    if (_selectedQualification == null) {
      _showMessage('Please select your highest qualification.');
      return;
    }

    if (!_agreedToTerms) {
      _showMessage(
        'Please accept the Agreement & Consent before submitting.',
      );
      return;
    }

    const requiredDocuments = [
      'cv',
      'qualification',
      'nationalId',
      'photo',
    ];

    for (final documentType in requiredDocuments) {
      final PlatformFile? file = _selectedDocuments[documentType];

      if (file == null) {
        final String label = switch (documentType) {
          'cv' => 'CV / Resume',
          'qualification' => 'Qualification Certificate',
          'nationalId' => 'National ID',
          'photo' => 'Applicant Photo',
          _ => documentType,
        };

        _showMessage('$label is required.');
        return;
      }

      if ((await file.length()) == 0) {
        _showMessage(
          '${file.name} could not be read. Please select it again.',
        );
        return;
      }
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Your Google account session has expired. Please sign in again.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String? idToken = await user.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Unable to obtain your authentication token.',
        );
      }

      final createResponse = await http.post(
        Uri.parse('$_backendUrl/job-applications/create'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'applicantName': user.displayName ?? '',
          'position': _selectedPosition,
          'qualification': _selectedQualification,
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'nationalIdNumber': _nationalIdController.text.trim(),
          'dateOfBirth': _dateOfBirthController.text.trim(),
          'gender': _selectedGender,
          'residentialAddress': _addressController.text.trim(),
          'cityDistrict': _cityController.text.trim(),
          'country': _countryController.text.trim(),
          'institution': _schoolController.text.trim(),
          'fieldOfStudy': _fieldOfStudyController.text.trim(),
          'graduationYear': _graduationYearController.text.trim(),
          'workExperience': _experienceController.text.trim(),
          'agreementAccepted': true,
        }),
      );

      Map<String, dynamic> createBody = {};

      try {
        final decoded = jsonDecode(createResponse.body);
        if (decoded is Map<String, dynamic>) {
          createBody = decoded;
        }
      } catch (_) {}

      if (createResponse.statusCode != 201 ||
          createBody['success'] != true) {
        throw Exception(
          createBody['message']?.toString() ??
              'Unable to create your application.',
        );
      }

      final String applicationId =
          createBody['applicationId']?.toString() ?? '';

      final String applicationNumber =
          createBody['applicationNumber']?.toString() ?? '';

      if (applicationId.isEmpty) {
        throw Exception(
          'The server did not return an application ID.',
        );
      }


      for (final documentType in requiredDocuments) {
        final PlatformFile file =
            _selectedDocuments[documentType]!;

        await _uploadDocument(
          applicationId,
          documentType,
          file,
        );
      }

      final String? finalIdToken =
          await FirebaseAuth.instance.currentUser?.getIdToken();

      if (finalIdToken == null || finalIdToken.isEmpty) {
        throw Exception(
          'Unable to verify your authentication before final submission.',
        );
      }

      final finalizeResponse = await http.post(
        Uri.parse(
          '$_backendUrl/job-applications/$applicationId/finalize',
        ),
        headers: {
          'Authorization': 'Bearer $finalIdToken',
          'Content-Type': 'application/json',
        },
      );

      Map<String, dynamic> finalizeBody = {};

      try {
        final decoded = jsonDecode(finalizeResponse.body);
        if (decoded is Map<String, dynamic>) {
          finalizeBody = decoded;
        }
      } catch (_) {}

      if (finalizeResponse.statusCode != 200 ||
          finalizeBody['success'] != true) {
        throw Exception(
          finalizeBody['message']?.toString() ??
              'Unable to finalize your application.',
        );
      }

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Application Submitted'),
            content: SelectableText(
              'Your application has been submitted successfully.\n\n'
              'Application Number:\n'
              '${finalizeBody['applicationNumber'] ?? applicationNumber}\n\n'
              'Status: Submitted\n'
              'Review Status: Pending',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }

    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ApplicantLoginPage()),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _documentUploadCard(
    String documentType,
    String title,
    String description,
    IconData icon,
  ) {
    final PlatformFile? selectedFile =
        _selectedDocuments[documentType];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          selectedFile == null
              ? description
              : selectedFile.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: OutlinedButton(
          onPressed: () => _pickDocument(documentType),
          child: Text(
            selectedFile == null ? 'Upload' : 'Change',
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument(String documentType) async {
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (file == null) {
      return;
    }

    final int fileSize = await file.length() ?? 0;

    if (fileSize > 10 * 1024 * 1024) {
      _showMessage('File must not exceed 10 MB.');
      return;
    }

    if (fileSize == 0) {
      _showMessage('The selected file is empty or could not be read.');
      return;
    }

    if (documentType == 'photo') {
      final String extension =
          file.extension?.toLowerCase() ?? '';

      if (extension != 'jpg' &&
          extension != 'jpeg' &&
          extension != 'png') {
        _showMessage(
          'Applicant photo must be JPG, JPEG or PNG.',
        );
        return;
      }
    }

    setState(() {
      _selectedDocuments[documentType] = file;
    });

    _showMessage(
      '${file.name} selected successfully.',
    );
  }
  @override
  Widget build(BuildContext context) {
    final User? user = _currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MobiFlex Job Application'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Online Job Application',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),

                      _sectionTitle(
                        '1. Position',
                        'Select the position you want to apply for.',
                      ),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedPosition,
                        decoration: const InputDecoration(
                          labelText: 'Position',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Manager',
                            child: Text('Manager'),
                          ),
                          DropdownMenuItem(
                            value: 'Agent',
                            child: Text('Agent'),
                          ),
                          DropdownMenuItem(
                            value: 'Sales Representative (SR)',
                            child: Text('Sales Representative (SR)'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPosition = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Position is required';
                          }
                          return null;
                        },
                      ),

                      _sectionTitle(
                        '2. Highest Qualification',
                        'Select your highest completed qualification.',
                      ),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedQualification,
                        decoration: const InputDecoration(
                          labelText: 'Highest Qualification',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Certificate',
                            child: Text('Certificate'),
                          ),
                          DropdownMenuItem(
                            value: 'Diploma',
                            child: Text('Diploma'),
                          ),
                          DropdownMenuItem(
                            value: 'Degree',
                            child: Text('Degree'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedQualification = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Qualification is required';
                          }
                          return null;
                        },
                      ),

                      _sectionTitle(
                        '3. Personal Details',
                        'Provide your official personal information.',
                      ),

                      _textField(_firstNameController, 'First Name'),
                      _textField(
                        _middleNameController,
                        'Middle Name',
                        required: false,
                      ),
                      _textField(_lastNameController, 'Last Name'),
                      _textField(
                        _phoneController,
                        'Phone Number',
                        keyboardType: TextInputType.phone,
                      ),
                      _textField(_nationalIdController, 'National ID Number'),

                      TextFormField(
                        controller: _dateOfBirthController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: _selectDateOfBirth,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Date of Birth is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gender is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _textField(
                        _addressController,
                        'Residential Address',
                        maxLines: 2,
                      ),
                      _textField(_cityController, 'City / District'),
                      _textField(_countryController, 'Country'),

                      _sectionTitle(
                        '4. Education',
                        'Provide details of your highest qualification.',
                      ),

                      _textField(_schoolController, 'Institution / School'),
                      _textField(_fieldOfStudyController, 'Field of Study'),
                      _textField(
                        _graduationYearController,
                        'Graduation Year',
                        keyboardType: TextInputType.number,
                      ),

                      _sectionTitle(
                        '5. Work Experience',
                        'Tell us about your relevant work experience.',
                      ),

                      _textField(
                        _experienceController,
                        'Work Experience',
                        required: false,
                        maxLines: 6,
                      ),

                      _sectionTitle(
                        '6. Required Documents',
                        'Documents will be stored securely and accessed '
                            'only by authorized recruitment staff.',
                      ),

                      _documentUploadCard(
                        'cv',
                        'CV / Resume',
                        'Upload your current CV or resume.',
                        Icons.description_outlined,
                      ),
                      _documentUploadCard(
                        'qualification',
                        'Qualification Certificate',
                        'Certificate, Diploma, or Degree document.',
                        Icons.school_outlined,
                      ),
                      _documentUploadCard(
                        'nationalId',
                        'National ID',
                        'Clear copy/photo of your National ID.',
                        Icons.badge_outlined,
                      ),
                      _documentUploadCard(
                        'photo',
                        'Applicant Photo',
                        'Recent passport-style photo.',
                        Icons.photo_camera_outlined,
                      ),

                      _sectionTitle(
                        '7. Agreement & Consent',
                        'Please read and accept before submitting.',
                      ),

                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'I confirm that the information and documents '
                            'provided in this application are correct and '
                            'genuine. I understand that MobiFlex African '
                            'may verify the information and documents for '
                            'recruitment purposes. I consent to the lawful '
                            'collection, review, storage, and processing of '
                            'my personal information for recruitment and '
                            'employment purposes. I understand that submitting '
                            'an application does not guarantee employment.',
                          ),
                        ),
                      ),

                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        title: const Text(
                          'I have read and agree to the Agreement & Consent.',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      _sectionTitle(
                        '8. Security',
                        'Your Google account identifies your application. '
                            'Your Google password is never stored by MobiFlex.',
                      ),

                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.security),
                          title: Text('Secure Applicant Identity'),
                          subtitle: Text(
                            'Your application is linked to your '
                            'authenticated Google account. Employment '
                            'permissions are created separately only after '
                            'approval.',
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitApplication,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            _isSubmitting
                                ? 'Validating Application...'
                                : 'Submit Job Application',
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'After submission, you will receive an '
                        'application number that can be used to check '
                        'your application status.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
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









