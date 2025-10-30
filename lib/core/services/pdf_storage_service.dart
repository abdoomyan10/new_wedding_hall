// core/services/pdf_storage_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class PdfStorageService {
  static Future<String?> savePdfToDevice(
    Uint8List pdfBytes,
    String fileName,
  ) async {
    try {
      Directory directory;
      if (Platform.isAndroid) {
        // محاولة الوصول إلى مجلد التحميلات أولاً
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory =
                await getExternalStorageDirectory() ??
                await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      return paymentReportsFolder;
    } catch (e) {
      print('❌ خطأ في إنشاء المجلد: $e');
      // استخدام getTemporaryDirectory كبديل
      final tempDirectory = await getTemporaryDirectory();
      final fallbackFolder = Directory('${tempDirectory.path}/PaymentReports');

      if (!await fallbackFolder.exists()) {
        await fallbackFolder.create(recursive: true);
      }

      return fallbackFolder;
    }
  }

  static Future<String> savePdfToDevice(pw.Document pdf, String fileName) async {
    try {
      final cleanFileName = _cleanFileName(fileName);
      final folder = await _getOrCreatePaymentReportsFolder();
      final file = File('${folder.path}/$cleanFileName');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      print('✅ تم حفظ ملف PDF بنجاح في: ${file.path}');
      return file.path;
    } catch (e) {
      print('❌ خطأ في حفظ ملف PDF: $e');
      // محاولة بديلة باستخدام Temporary Directory
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${_cleanFileName(fileName)}');
        final bytes = await pdf.save();
        await tempFile.writeAsBytes(bytes);
        print('✅ تم حفظ ملف PDF في المجلد المؤقت: ${tempFile.path}');
        return tempFile.path;
      } catch (fallbackError) {
        print('❌ فشل الحفظ في المجلد المؤقت: $fallbackError');
        throw Exception('فشل في حفظ ملف PDF: $e');
      }
    }
  }

  static String _cleanFileName(String fileName) {
    // إضافة .pdf إذا لم يكن موجوداً
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      fileName = '$fileName.pdf';
    }
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  static Future<List<File>> getSavedPdfFiles() async {
    try {
      final folder = await _getOrCreatePaymentReportsFolder();
      if (!await folder.exists()) {
        return [];
      }

      final List<FileSystemEntity> entities = await folder.list().toList();
      final List<File> pdfFiles = [];

      for (final entity in entities) {
        if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
          pdfFiles.add(entity);
        }
      }

      pdfFiles.sort((a, b) {
        try {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return bStat.modified.compareTo(aStat.modified);
        } catch (e) {
          return 0;
        }
      });

      print('📁 تم العثور على ${pdfFiles.length} ملف PDF للمدفوعات');
      return pdfFiles;
    } catch (e) {
      print('❌ خطأ في جلب ملفات المدفوعات المحفوظة: $e');
      // إرجاع قائمة فارغة بدلاً من إلقاء استثناء
      return [];
    }
  }

  static Future<bool> deleteSavedPdfFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('✅ تم حذف ملف PDF: $filePath');
        return true;
      } else {
        print('⚠️ ملف PDF غير موجود: $filePath');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في حذف ملف PDF: $e');
      return false;
    }
  }

  static Future<void> openPdfFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      print('❌ خطأ في فتح ملف PDF: $e');
      throw Exception('فشل في فتح ملف PDF: $e');
    }
  }

  // دالة مساعدة للتحقق من وجود الملف
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
