import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/profile_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/export_service.dart';
import '../utils/size_config.dart';
import 'themed_dialogs.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _selectedFormat = 'pdf'; // 'pdf', 'excel', or 'both'
  DateTimeRange? _selectedDateRange;
  bool _isExporting = false;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: theme.colorScheme.primary,
              headerForegroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _resetDateRange() {
    setState(() => _selectedDateRange = null);
  }

  Future<void> _handleExport() async {
    final profileProvider = context.read<ProfileProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final activeProfile = profileProvider.activeProfile;

    if (activeProfile == null) return;

    setState(() => _isExporting = true);

    final success = await ExportService.exportAndShare(
      transactions: transactionProvider.transactions,
      customers: transactionProvider.customers,
      profileName: activeProfile.name,
      dateRange: _selectedDateRange,
      exportFormat: _selectedFormat,
    );

    if (mounted) {
      setState(() => _isExporting = false);
      if (success) {
        Navigator.pop(context);
        ThemedDialogs.showSuccessSnackBar(context, 'Report exported successfully!');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate export file. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final activeProfileName = profileProvider.activeProfile?.name ?? 'Personal';

    final dateRangeFormat = DateFormat('MMM dd, yyyy');
    final dateRangeLabel = _selectedDateRange != null
        ? '${dateRangeFormat.format(_selectedDateRange!.start)} - ${dateRangeFormat.format(_selectedDateRange!.end)}'
        : 'All Time (No Filter)';

    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 10.w,
              height: 4,
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header title & active profile indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Export Reports',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 14.sp, color: theme.colorScheme.primary),
                    SizedBox(width: 1.w),
                    Text(
                      activeProfileName,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.5.h),

          // Format selection
          Text(
            'Export Format',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: theme.hintColor),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildFormatChip('pdf', 'PDF Document', Icons.picture_as_pdf_outlined),
              SizedBox(width: 2.w),
              _buildFormatChip('excel', 'Excel (.xlsx)', Icons.table_chart_outlined),
              SizedBox(width: 2.w),
              _buildFormatChip('both', 'Both', Icons.folder_zip_outlined),
            ],
          ),

          SizedBox(height: 3.h),

          // Date Range Selection
          Text(
            'Date Range Filter',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: theme.hintColor),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedDateRange != null
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                  width: _selectedDateRange != null ? 1.5 : 1.0,
                ),
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18.sp,
                    color: _selectedDateRange != null ? theme.colorScheme.primary : theme.hintColor,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      dateRangeLabel,
                      style: TextStyle(
                        fontWeight: _selectedDateRange != null ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  if (_selectedDateRange != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _resetDateRange,
                      tooltip: 'Reset Filter',
                    )
                  else
                    Icon(Icons.arrow_drop_down, color: theme.hintColor),
                ],
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isExporting ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _isExporting ? null : _handleExport,
                  icon: _isExporting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.share_outlined, size: 18),
                  label: Text(
                    _isExporting ? 'Generating...' : 'Export & Share',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(String value, String label, IconData icon) {
    final isSelected = _selectedFormat == value;
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFormat = value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : theme.hintColor,
                size: 20.sp,
              ),
              SizedBox(height: 0.6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
