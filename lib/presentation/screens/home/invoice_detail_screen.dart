import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/models/invoice_model.dart';
import '../../../providers/invoice_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/services/pdf_invoice_service.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    String formatDate(DateTime d) =>
        '${months[d.month - 1]} ${d.day.toString().padLeft(2,'0')}, ${d.year}';

    final statusColors = {
      'PAID': const Color(0xFF059669),
      'PENDING': const Color(0xFFD97706),
      'OVERDUE': const Color(0xFFDC2626),
    };
    final statusBg = {
      'PAID': const Color(0xFFECFDF5),
      'PENDING': const Color(0xFFFFFBEB),
      'OVERDUE': const Color(0xFFFEF2F2),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(invoice.invoiceNumber,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          // PDF Download button
          IconButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              await PdfInvoiceService.printOrDownloadInvoice(
                context: context,
                invoice: invoice,
                businessOwner: auth.currentUser,
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Download / Print PDF',
          ),
          Consumer<InvoiceProvider>(
            builder: (context, provider, _) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r)),
                      title: Text('Delete Invoice',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      content: Text(
                          'Delete ${invoice.invoiceNumber}? This action cannot be undone.',
                          style: GoogleFonts.inter()),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await provider.deleteInvoice(invoice.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                } else {
                  await provider.updateInvoiceStatus(invoice.id, value);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              itemBuilder: (_) => [
                if (invoice.status != 'PAID')
                  PopupMenuItem(
                    value: 'PAID',
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline,
                          color: Color(0xFF059669), size: 18),
                      SizedBox(width: 8.w),
                      Text('Mark as Paid', style: GoogleFonts.inter()),
                    ]),
                  ),
                if (invoice.status != 'PENDING')
                  PopupMenuItem(
                    value: 'PENDING',
                    child: Row(children: [
                      const Icon(Icons.pending_outlined,
                          color: Color(0xFFD97706), size: 18),
                      SizedBox(width: 8.w),
                      Text('Mark as Pending', style: GoogleFonts.inter()),
                    ]),
                  ),
                if (invoice.status != 'OVERDUE')
                  PopupMenuItem(
                    value: 'OVERDUE',
                    child: Row(children: [
                      const Icon(Icons.warning_amber_outlined,
                          color: Color(0xFFDC2626), size: 18),
                      SizedBox(width: 8.w),
                      Text('Mark as Overdue', style: GoogleFonts.inter()),
                    ]),
                  ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                    SizedBox(width: 8.w),
                    Text('Delete Invoice',
                        style: GoogleFonts.inter(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // ── Invoice Header Card ──────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TAX INVOICE',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            invoice.invoiceNumber,
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: statusBg[invoice.status],
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          invoice.status,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColors[invoice.status],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Total Amount Due',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '₹ ${invoice.totalWithGst.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (invoice.gstRate > 0)
                    Text(
                      'Inclusive of GST @ ${invoice.gstRate.toInt()}%',
                      style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.7)),
                    ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── PDF Action Row ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _actionChip(
                    context: context,
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'View / Print PDF',
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF5F3FF),
                    onTap: () async {
                      final auth = context.read<AuthProvider>();
                      await PdfInvoiceService.printOrDownloadInvoice(
                        context: context,
                        invoice: invoice,
                        businessOwner: auth.currentUser,
                      );
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _actionChip(
                    context: context,
                    icon: Icons.share_outlined,
                    label: 'Share Invoice',
                    color: const Color(0xFF0891B2),
                    bgColor: const Color(0xFFECFEFF),
                    onTap: () async {
                      final auth = context.read<AuthProvider>();
                      await PdfInvoiceService.printOrDownloadInvoice(
                        context: context,
                        invoice: invoice,
                        businessOwner: auth.currentUser,
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // ── Client & Dates ───────────────────────────────
            _detailCard(children: [
              _detailRow(Icons.person_outline, 'Billed To', invoice.clientName,
                  bold: true),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              _detailRow(Icons.calendar_today_outlined, 'Issue Date',
                  formatDate(invoice.issueDate)),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              _detailRow(
                Icons.event_outlined,
                'Payment Due',
                formatDate(invoice.dueDate),
                valueColor: invoice.status == 'OVERDUE'
                    ? const Color(0xFFDC2626)
                    : null,
              ),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              _detailRow(Icons.access_time_outlined, 'Created On',
                  formatDate(invoice.createdAt)),
            ]),

            SizedBox(height: 12.h),

            // ── Amount Breakdown ─────────────────────────────
            _detailCard(children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.calculate_outlined,
                        color: const Color(0xFF2563EB), size: 18.sp),
                  ),
                  SizedBox(width: 10.w),
                  Text('Amount Breakdown',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: const Color(0xFF1E293B))),
                ],
              ),
              SizedBox(height: 16.h),
              _amountRow('Base Amount', invoice.amount),
              if (invoice.gstRate > 0) ...[
                SizedBox(height: 8.h),
                _amountRow('CGST (${(invoice.gstRate / 2).toStringAsFixed(1)}%)',
                    invoice.gstAmount / 2),
                SizedBox(height: 4.h),
                _amountRow('SGST (${(invoice.gstRate / 2).toStringAsFixed(1)}%)',
                    invoice.gstAmount / 2),
              ],
              const Divider(height: 20, color: Color(0xFFE2E8F0)),
              _amountRow('Grand Total', invoice.totalWithGst, bold: true),
            ]),

            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _detailCard(children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.notes_outlined,
                          color: const Color(0xFF64748B), size: 18.sp),
                    ),
                    SizedBox(width: 10.w),
                    Text('Notes & Terms',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: const Color(0xFF1E293B))),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(invoice.notes!,
                    style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF374151),
                        height: 1.6)),
              ]),
            ],

            SizedBox(height: 12.h),

            // ── Status Change Buttons ────────────────────────
            if (invoice.status != 'PAID')
              Consumer<InvoiceProvider>(
                builder: (ctx, provider, _) => SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await provider.updateInvoiceStatus(invoice.id, 'PAID');
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text('Invoice marked as Paid.',
                              style: GoogleFonts.inter()),
                          backgroundColor: const Color(0xFF059669),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.all(16.w),
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text('Mark as Paid',
                        style: GoogleFonts.inter(
                            fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(8.r)),
              child: Icon(icon, size: 16.sp, color: color),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        SizedBox(width: 12.w),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 13.sp, color: const Color(0xFF64748B)),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _amountRow(String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: bold ? 14.sp : 13.sp,
            color: bold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          '₹ ${amount.toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: bold ? 16.sp : 13.sp,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: bold ? const Color(0xFF2563EB) : const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
