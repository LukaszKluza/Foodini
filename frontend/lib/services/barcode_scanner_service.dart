import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerService {
  static final BarcodeScannerService _instance =
      BarcodeScannerService._internal();

  factory BarcodeScannerService() => _instance;

  BarcodeScannerService._internal();

  final MobileScannerController _controller = MobileScannerController();

  Future<String?> scanBarcodeFromGallery(XFile uploadedImage) async {
    try {
      final result = await _controller.analyzeImage(uploadedImage.path);

      if (result != null && result.barcodes.isNotEmpty) {
        return result.barcodes.first.rawValue;
      }
    } catch (e) {
      Exception('Error while scanning barcode: $e');
    }
    return null;
  }
}
