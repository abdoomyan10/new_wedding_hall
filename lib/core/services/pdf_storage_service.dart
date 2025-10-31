// core/services/pdf_storage_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class PdfStorageService {
  // دالة مساعدة لإنشاء مجلد التقارير
  static Future<Directory> _getOrCreatePaymentReportsFolder() async {
    try {
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

      // إنشاء مجلد PaymentReports داخل المجلد الرئيسي
      final paymentReportsFolder = Directory('${directory.path}/PaymentReports');
      if (!await paymentReportsFolder.exists()) {
        await paymentReportsFolder.create(recursive: true);
      }

      return paymentReportsFolder;
    } catch (e) {
      // استخدام getTemporaryDirectory كبديل
      final tempDirectory = await getTemporaryDirectory();
      final fallbackFolder = Directory('${tempDirectory.path}/PaymentReports');

      if (!await fallbackFolder.exists()) {
        await fallbackFolder.create(recursive: true);
      }

      return fallbackFolder;
    }
  }

  // الدالة الرئيسية لحفظ PDF
  static Future<String> savePdfToDevice(pw.Document pdf, String fileName) async {
    try {
      final cleanFileName = _cleanFileName(fileName);
      final folder = await _getOrCreatePaymentReportsFolder();
      final file = File('${folder.path}/$cleanFileName');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      debugPrint('✅ تم حفظ ملف PDF بنجاح في: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ خطأ في حفظ ملف PDF: $e');
      // محاولة بديلة باستخدام Temporary Directory
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${_cleanFileName(fileName)}');
        final bytes = await pdf.save();
        await tempFile.writeAsBytes(bytes);
        debugPrint('✅ تم حفظ ملف PDF في المجلد المؤقت: ${tempFile.path}');
        return tempFile.path;
      } catch (fallbackError) {
        debugPrint('❌ فشل الحفظ في المجلد المؤقت: $fallbackError');
        throw Exception('فشل في حفظ ملف PDF: $e');
      }
    }
  }

  // دالة بديلة لحفظ PDF من Uint8List (إذا كنت تحتاجها)
  static Future<String> savePdfBytesToDevice(Uint8List pdfBytes, String fileName) async {
    try {
      final cleanFileName = _cleanFileName(fileName);
      final folder = await _getOrCreatePaymentReportsFolder();
      final file = File('${folder.path}/$cleanFileName');
      await file.writeAsBytes(pdfBytes);

      debugPrint('✅ تم حفظ ملف PDF بنجاح في: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ خطأ في حفظ ملف PDF: $e');
      // محاولة بديلة باستخدام Temporary Directory
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${_cleanFileName(fileName)}');
        await tempFile.writeAsBytes(pdfBytes);
        debugPrint('✅ تم حفظ ملف PDF في المجلد المؤقت: ${tempFile.path}');
        return tempFile.path;
      } catch (fallbackError) {
        debugPrint('❌ فشل الحفظ في المجلد المؤقت: $fallbackError');
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

      debugPrint('📁 تم العثور على ${pdfFiles.length} ملف PDF للمدفوعات');
      return pdfFiles;
    } catch (e) {
      debugPrint('❌ خطأ في جلب ملفات المدفوعات المحفوظة: $e');
      // إرجاع قائمة فارغة بدلاً من إلقاء استثناء
      return [];
    }
  }

  static Future<bool> deleteSavedPdfFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ تم حذف ملف PDF: $filePath');
        return true;
      } else {
        debugPrint('⚠️ ملف PDF غير موجود: $filePath');
        return false;
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف ملف PDF: $e');
      return false;
    }
  }

  static Future<void> openPdfFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint('❌ خطأ في فتح ملف PDF: $e');
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

  // دالة لمسح جميع ملفات PDF القديمة (اختيارية)
  static Future<void> clearOldPdfFiles({int days = 30}) async {
    try {
      final files = await getSavedPdfFiles();
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      for (final file in files) {
        try {
          final stat = file.statSync();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
            debugPrint('🗑️ تم حذف الملف القديم: ${file.path}');
          }
        } catch (e) {
          debugPrint('⚠️ خطأ في معالجة الملف: ${file.path} - $e');
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في مسح الملفات القديمة: $e');
    }
  }
}