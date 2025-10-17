// core/services/pdf_storage_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class PdfStorageService {
  static Future<String?> savePdfToDevice(Uint8List pdfBytes, String fileName) async {
    try {
      // طلب الإذن للتخزين (لـ Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          final permissionResult = await Permission.storage.request();
          if (!permissionResult.isGranted) {
            throw Exception('تم رفض إذن التخزين');
          }
        }
      }

      // الحصول على directory للتخزين
      Directory directory;
      if (Platform.isAndroid) {
        // محاولة الوصول إلى مجلد التحميلات أولاً
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      // التأكد من وجود المجلد
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // تنظيف اسم الملف من الأحرف غير المسموحة
      final cleanFileName = _cleanFileName(fileName);

      // التأكد من وجود الملف باسم فريد
      String fullPath = '${directory.path}/$cleanFileName.pdf';
      File file = File(fullPath);

      // إذا الملف موجود، نضيف رقم
      int counter = 1;
      while (await file.exists()) {
        fullPath = '${directory.path}/${cleanFileName}_$counter.pdf';
        file = File(fullPath);
        counter++;
      }

      // حفظ الملف
      await file.writeAsBytes(pdfBytes, flush: true);

      print('✅ تم حفظ الملف بنجاح في: $fullPath');
      return fullPath;
    } catch (e) {
      print('❌ خطأ في حفظ PDF: $e');
      return null;
    }
  }

  static String _cleanFileName(String fileName) {
    // إزالة الأحرف غير المسموحة في أسماء الملفات
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  static Future<bool> openPdfFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final result = await OpenFile.open(filePath);
        return result.type == ResultType.done;
      } else {
        print('❌ الملف غير موجود: $filePath');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في فتح الملف: $e');
      return false;
    }
  }

  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }
    return true;
  }
}