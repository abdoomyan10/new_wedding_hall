// features/reports/presentation/pages/saved_reports_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/report_cubit.dart';

class SavedReportsPage extends StatefulWidget {
  const SavedReportsPage({super.key});

  @override
  State<SavedReportsPage> createState() => _SavedReportsPageState();
}

class _SavedReportsPageState extends State<SavedReportsPage> {
  late Future<List<File>> _pdfFilesFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  void _loadPdfFiles() {
    setState(() {
      _pdfFilesFuture = context.read<ReportCubit>().getSavedPdfFiles();
      _isRefreshing = true;
    });

    // إخفاء مؤشر التحديث بعد ثانية
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التقارير المحفوظة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.deepRed,
        foregroundColor: AppColors.paleGold,
        elevation: 0,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.paleGold,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPdfFiles,
              tooltip: 'تحديث القائمة',
            ),
        ],
      ),
      body: BlocProvider.value(
        value: context.read<ReportCubit>(),
        child: Container(
          color: AppColors.background,
          child: FutureBuilder<List<File>>(
            future: _pdfFilesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !_isRefreshing) {
                return _buildLoadingState();
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPdfFiles,
        backgroundColor: AppColors.deepRed,
        foregroundColor: AppColors.paleGold,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.deepRed,
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل التقارير...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.deepRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تعذر تحميل التقارير المحفوظة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'الخطأ: $error',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPdfFiles,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepRed,
                foregroundColor: AppColors.paleGold,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.paleGold.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.paleGold.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.folder_open,
                size: 80,
                color: AppColors.paleGold.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد تقارير محفوظة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.deepRed,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'سيظهر هنا جميع تقارير PDF المحفوظة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك حفظ التقارير من صفحة التقارير الرئيسية',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة للتقارير'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepRed,
                foregroundColor: AppColors.paleGold,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesList(List<File> files) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadPdfFiles();
      },
      backgroundColor: AppColors.background,
      color: AppColors.deepRed,
      child: ListView.builder(
        itemCount: files.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final file = files[index];
          final fileName = file.path.split('/').last;
          final fileSize = _formatFileSize(file);
          final fileDate = _getFileDate(file);
          final fileTime = _getFileTime(file);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.deepRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                title: Text(
                  _formatFileName(fileName),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.insert_drive_file, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          fileSize,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          fileDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fileTime,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
                      ),
                      tooltip: 'فتح التقرير',
                      onPressed: () => _openFile(file),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete, size: 18, color: Colors.red),
                      ),
                      tooltip: 'حذف التقرير',
                      onPressed: () => _deleteFile(context, file),
                    ),
                  ],
                ),
                onTap: () => _openFile(file),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatFileName(String fileName) {
    // إزالة الامتداد وتنسيق الاسم
    final nameWithoutExt = fileName.replaceAll('.pdf', '');
    return nameWithoutExt.replaceAll('_', ' ');
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
      final modified = stat.modified;
      return '${modified.year}-${modified.month.toString().padLeft(2, '0')}-${modified.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'غير معروف';
    }
  }

  String _getFileTime(File file) {
    try {
      final stat = file.statSync();
      final modified = stat.modified;
      return '${modified.hour.toString().padLeft(2, '0')}:${modified.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  Future<void> _openFile(File file) async {
    try {
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في فتح الملف: ${result.message}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في فتح الملف: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteFile(BuildContext context, File file) async {
    final fileName = _formatFileName(file.path.split('/').last);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            const Text(
              'تأكيد الحذف',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من حذف التقرير التالي؟'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.deepRed,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(file),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ لا يمكن التراجع عن هذا الإجراء.',
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
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف التقرير'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await context.read<ReportCubit>().deleteSavedPdfFile(file.path);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف التقرير بنجاح'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadPdfFiles();
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في حذف التقرير'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في حذف التقرير: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}