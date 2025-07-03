// service.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

class TFLiteService {
  TFLiteService._();
  static final instance = TFLiteService._();

  late Interpreter _interpreter;
  late Map<String, dynamic> _deskripsiKentang;
  late List<String> _labels;
  bool _loaded = false;

  Future<bool> loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions();

      // Copy model.tflite to temp dir
      print('📦 Memuat model dari assets/model_kentang.tflite...');
      print('📂 File list di assets:');
      print(await rootBundle.loadString('AssetManifest.json'));
      final descRaw = await rootBundle.loadString(
        'assets/kentang_deskripsi.json',
      );
      _deskripsiKentang = json.decode(descRaw);

      final modelData = await rootBundle.load('assets/model_kentang.tflite');
      final modelPath = await _writeToFile(modelData, 'model_kentang.tflite');
      _interpreter = await Interpreter.fromFile(
        File(modelPath),
        options: interpreterOptions,
      );
      print('✅ Model berhasil dimuat dari: $modelPath');

      // Load labels
      print('📄 Memuat label dari assets/labels.txt...');
      final labelRaw = await rootBundle.loadString('assets/labels.txt');
      _labels = labelRaw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      print('✅ Label berhasil dimuat (${_labels.length} label)');

      _loaded = true;
      print('🚀 Model siap digunakan');
      return true;
    } catch (e) {
      print('❌ Gagal load model: $e');
      return false;
    }
  }

  Future<String> _writeToFile(ByteData data, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File(path.join(dir.path, filename));
    await file.writeAsBytes(data.buffer.asUint8List());
    return file.path;
  }

  Future<List<Map<String, dynamic>>> classifyImage(File imageFile) async {
    if (!_loaded) {
      print('⚠️ Model belum dimuat. Panggil loadModel() terlebih dahulu.');
      return [];
    }

    final raw = imageFile.readAsBytesSync();
    final image = img.decodeImage(raw);
    if (image == null) {
      print('❌ Gagal memuat gambar');
      return [];
    }

    final inputSize = 160;
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) => List.generate(3, (c) {
            final pixel = resized.getPixel(x, y);
            switch (c) {
              case 0:
                return img.getRed(pixel) / 255.0;
              case 1:
                return img.getGreen(pixel) / 255.0;
              case 2:
                return img.getBlue(pixel) / 255.0;
              default:
                return 0.0;
            }
          }),
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
    _interpreter.run(input, output);

    final result = <Map<String, dynamic>>[];

    for (int i = 0; i < _labels.length; i++) {
      result.add({'label': _labels[i], 'confidence': output[0][i]});
    }

    result.sort((a, b) => b['confidence'].compareTo(a['confidence']));

    final topResult = result.first;
    final labelUtama = topResult['label'];

    // Langsung gunakan label sebagai kunci di JSON
    final detail = _deskripsiKentang[labelUtama] ?? {};

    // Debug untuk melihat apa yang terjadi
    print('📌 Label: $labelUtama');
    print('📌 Detail ditemukan: ${detail.isNotEmpty}');

    return [
      {
        'label': labelUtama,
        'confidence': topResult['confidence'],
        'penyebab': detail['penyebab'],
        'menular': detail['menular'],
        'deskripsi': detail['deskripsi'],
        'caraMengatasi': detail['caraMengatasi'],
      },
      ...result.skip(1).take(2), // sisanya tanpa detail
    ];
  }
}
