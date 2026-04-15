import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../data/models/invoice_model.dart';
import 'add_invoice_screen.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Invoices',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddInvoiceScreen()),
            );
          },
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text('New Invoice',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Filter Tabs
              _buildFilterTabs(context, provider),

              // Invoice List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.invoices.isEmpty
                        ? _buildEmptyState(context, provider.filterStatus)
                        : RefreshIndicator(
                            onRefresh: provider.loadInvoices,
                            child: ListView.separated(
                              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                              itemCount: provider.invoices.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 10.h),
                              itemBuilder: (_, index) => _buildInvoiceCard(
                                context,
                                provider.invoices[index],
                                provider,
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, InvoiceProvider provider) {
    final filters = ['ALL', 'PAID', 'PENDING', 'OVERDUE'];
    final colors = {
      'ALL': const Color(0xFF2563EB),
      'PAID': const Color(0xFF059669),
      'PENDING': const Color(0xFFD97706),
      'OVERDUE': const Color(0xFFDC2626),
    };

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = provider.filterStatus == filter;
            final color = colors[filter] ?? const Color(0xFF2563EB);
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => provider.setFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    filter,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined,
                size: 48.sp, color: const Color(0xFF2563EB)),
          ),
          SizedBox(height: 16.h),
          Text(
            filter == 'ALL' ? 'No Invoices Yet' : 'No $filter Invoices',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            filter == 'ALL'
                ? 'Create your first invoice to get started'
                : 'No invoices with $filter status',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          if (filter == 'ALL') ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddInvoiceScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(
      BuildContext context, InvoiceModel invoice, InvoiceProvider provider) {
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
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final issueDate =
        '${months[invoice.issueDate.month - 1]} ${invoice.issueDate.day}, ${invoice.issueDate.year}';
    final dueDate =
        '${months[invoice.dueDate.month - 1]} ${invoice.dueDate.day}, ${invoice.dueDate.year}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InvoiceDetailScreen(invoice: invoice),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.receipt_outlined,
                          color: const Color(0xFF2563EB), size: 18.sp),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          invoice.clientName,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusBg[invoice.status],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    invoice.status,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColors[invoice.status],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount',
                        style: GoogleFonts.inter(
                            fontSize: 11.sp, color: const Color(0xFF64748B))),
                    Text(
                      '₹${_formatAmount(invoice.amount)}',
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (invoice.gstRate > 0)
                      Text(
                        '+GST ${invoice.gstRate.toInt()}% = ₹${_formatAmount(invoice.totalWithGst)}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Due Date',
                        style: GoogleFonts.inter(
                            fontSize: 11.sp, color: const Color(0xFF64748B))),
                    Text(
                      dueDate,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: invoice.status == 'OVERDUE'
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Issued: $issueDate',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (invoice.status == 'PENDING') ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          provider.updateInvoiceStatus(invoice.id, 'OVERDUE'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      child: Text('Mark Overdue',
                          style: GoogleFonts.inter(
                              fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          provider.updateInvoiceStatus(invoice.id, 'PAID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      child: Text('Mark Paid',
                          style: GoogleFonts.inter(
                              fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      final formatted = amount.toStringAsFixed(2);
      return formatted.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return amount.toStringAsFixed(2);
  }
}
