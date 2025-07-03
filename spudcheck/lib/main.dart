// main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spudcheck/service.dart';
import 'package:spudcheck/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeteksiKentang',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4E3D),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B6F47),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(), // Change this to SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  List<Map<String, dynamic>> _predictions = [];
  String _status = 'Memuat model AI...';
  bool _isLoading = false;
  bool _showResults = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    loadModelAndLabels();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> loadModelAndLabels() async {
    final result = await TFLiteService.instance.loadModel();
    setState(() {
      _status = result ? '✅ Model siap digunakan' : '❌ Gagal memuat model';
    });
    if (result) {
      _fadeController.forward();
    }
  }

  Future<void> predictImage(File image) async {
    setState(() {
      _isLoading = true;
      _showResults = false;
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    final preds = await TFLiteService.instance.classifyImage(image);

    // Debug untuk melihat isi prediksi
    print('🔍 Prediksi:');
    for (var pred in preds) {
      print('  - ${pred['label']}: ${pred['confidence']}');
      print('    Deskripsi: ${pred['deskripsi']}');
      print('    Kegunaan: ${pred['kegunaan']}');
    }

    setState(() {
      _image = image;
      _predictions = preds;
      _isLoading = false;
      _showResults = true;
    });

    _slideController.forward();
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      _slideController.reset();
      predictImage(File(picked.path));
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Choose Image Source',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _ImageSourceCard(
                          icon: Icons.camera_alt_rounded,
                          label: 'Kamera',
                          onTap: () {
                            Navigator.pop(context);
                            pickImage(ImageSource.camera);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ImageSourceCard(
                          icon: Icons.photo_library_rounded,
                          label: 'Galeri',
                          onTap: () {
                            Navigator.pop(context);
                            pickImage(ImageSource.gallery);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        6,
                      ), // Reduced padding for image
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          255,
                          234,
                          204,
                        ), // Specify a custom color
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/spudcheck.png',
                        width: 48, // Set appropriate width
                        height: 48, // Set appropriate height
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SpudCheck',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Deteksi Kentang dengan AI',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Image Display
                      if (_image != null) ...[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.file(
                              _image!,
                              height: 320,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ] else ...[
                        // Empty State
                        Container(
                          height: 320,
                          width: 320,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 48,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada gambar dipilih',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ambil foto atau pilih dari galeri',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Loading Indicator
                      if (_isLoading) ...[
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Menganalisis kentang...',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Results
                      if (_showResults && _predictions.isNotEmpty) ...[
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main Result Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primaryContainer,
                                      colorScheme.primaryContainer.withOpacity(
                                        0.7,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.verified_rounded,
                                            color: colorScheme.onPrimary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Hasil Deteksi',
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: colorScheme
                                                          .onPrimaryContainer
                                                          .withOpacity(0.8),
                                                    ),
                                              ),
                                              Text(
                                                _predictions[0]['label'],
                                                style: theme
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colorScheme
                                                          .onPrimaryContainer,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            '${(_predictions[0]['confidence'] * 100).toStringAsFixed(1)}%',
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  color: colorScheme.onPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Details Cards untuk kentang
                              if (_predictions[0]['deskripsi'] != null) ...[
                                _DetailCard(
                                  icon: Icons.description_rounded,
                                  title: 'Deskripsi',
                                  content: _predictions[0]['deskripsi'],
                                  colorScheme: colorScheme,
                                ),
                                const SizedBox(height: 12),
                              ],

                              if (_predictions[0]['penyebab'] != null &&
                                  _predictions[0]['penyebab'] != '-') ...[
                                _DetailCard(
                                  icon: Icons.bug_report_rounded,
                                  title: 'Penyebab',
                                  content: _predictions[0]['penyebab'],
                                  colorScheme: colorScheme,
                                ),
                                const SizedBox(height: 12),
                              ],

                              Row(
                                children: [
                                  Expanded(
                                    child: _DetailCard(
                                      icon: _predictions[0]['menular'] == true
                                          ? Icons.warning_rounded
                                          : Icons.check_circle_rounded,
                                      title: 'Menular',
                                      content:
                                          _predictions[0]['menular'] == true
                                          ? 'Ya'
                                          : 'Tidak',
                                      colorScheme: colorScheme,
                                      isCompact: true,
                                      isWarning:
                                          _predictions[0]['menular'] == true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Tambahkan card status jika diperlukan
                                  Expanded(
                                    child: _DetailCard(
                                      icon:
                                          _predictions[0]['label'] ==
                                              'Healthy Potatoes'
                                          ? Icons.health_and_safety_rounded
                                          : Icons.medical_services_rounded,
                                      title: 'Status',
                                      content:
                                          _predictions[0]['label'] ==
                                              'Healthy Potatoes'
                                          ? 'Sehat'
                                          : 'Bermasalah',
                                      colorScheme: colorScheme,
                                      isCompact: true,
                                      isWarning:
                                          _predictions[0]['label'] !=
                                          'Healthy Potatoes',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              if (_predictions[0]['caraMengatasi'] != null &&
                                  _predictions[0]['caraMengatasi'] != '-') ...[
                                _DetailCard(
                                  icon: Icons.medical_information_rounded,
                                  title: 'Cara Mengatasi',
                                  content: _predictions[0]['caraMengatasi'],
                                  colorScheme: colorScheme,
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Other Possibilities
                              if (_predictions.length > 1) ...[
                                Text(
                                  'Kemungkinan Lainnya',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._predictions
                                    .skip(1)
                                    .map(
                                      (p) => Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                p['label'],
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ),
                                            Text(
                                              '${(p['confidence'] * 100).toStringAsFixed(1)}%',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showImageSourceBottomSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.camera_enhance_rounded, color: Colors.white),
          label: const Text(
            'Pindai Kentang',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _ImageSourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final ColorScheme colorScheme;
  final bool isCompact;
  final bool isWarning;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.colorScheme,
    this.isCompact = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.red.withOpacity(0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: isWarning
            ? Border.all(color: Colors.red.withOpacity(0.3))
            : Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isWarning ? Colors.red : colorScheme.primary,
                size: isCompact ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!isCompact) const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isCompact ? FontWeight.w600 : FontWeight.w500,
              color: isWarning ? Colors.red.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }
}
