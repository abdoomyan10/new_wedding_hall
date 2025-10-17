// features/payments/presentation/pages/saved_payments_reports_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import '../cubit/payment_cubit.dart';

class SavedPaymentsReportsPage extends StatefulWidget {
  const SavedPaymentsReportsPage({super.key});

  @override
  State<SavedPaymentsReportsPage> createState() => _SavedPaymentsReportsPageState();
}

class _SavedPaymentsReportsPageState extends State<SavedPaymentsReportsPage> {
  late Future<List<File>> _pdfFilesFuture;

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  void _loadPdfFiles() {
    setState(() {
      _pdfFilesFuture = context.read<PaymentCubit>().getSavedPdfFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقارير المدفوعات المحفوظة'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPdfFiles,
            tooltip: 'تحديث القائمة',
          ),
        ],
      ),
      body: FutureBuilder<List<File>>(
        future: _pdfFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final files = snapshot.data!;
          return _buildFilesList(files);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPdfFiles,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'حدث خطأ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'خطأ: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPdfFiles,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'لا توجد تقارير محفوظة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيظهر هنا جميع تقارير PDF المحفوظة للمدفوعات',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList(List<File> files) {
    return ListView.builder(
      itemCount: files.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final file = files[index];
        final fileName = file.path.split('/').last;
        final fileSize = _formatFileSize(file);
        final fileDate = _getFileDate(file);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
            title: Text(
              fileName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الحجم: $fileSize'),
                Text('التاريخ: $fileDate'),
                Text(
                  _getShortPath(file.path),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.open_in_new, color: Colors.blue),
                  tooltip: 'فتح الملف',
                  onPressed: () => OpenFile.open(file.path),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف الملف',
                  onPressed: () => _deleteFile(context, file),
                ),
              ],
            ),
            onTap: () => OpenFile.open(file.path),
          ),
        );
      },
    );
  }

  String _formatFileSize(File file) {
    try {
      final size = file.lengthSync();
      if (size < 1024) {
        return '$size بايت';
      } else if (size < 1048576) {
        return '${(size / 1024).toStringAsFixed(1)} ك.ب';
      } else {
        return '${(size / 1048576).toStringAsFixed(1)} م.ب';
      }
    } catch (e) {
      return 'غير معروف';
    }
  }

  String _getFileDate(File file) {
    try {
      final stat = file.statSync();
      final date = stat.modified;
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'غير معروف';
    }
  }

  String _getShortPath(String fullPath) {
    if (fullPath.length > 50) {
      return '...${fullPath.substring(fullPath.length - 50)}';
    }
    return fullPath;
  }

  Future<void> _deleteFile(BuildContext context, File file) async {
    final fileName = file.path.split('/').last;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من حذف الملف التالي؟'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<PaymentCubit>().deleteSavedPdfFile(file.path);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حذف الملف بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadPdfFiles();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في حذف الملف'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}