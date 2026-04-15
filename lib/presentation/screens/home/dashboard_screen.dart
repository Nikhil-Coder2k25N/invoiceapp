import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../providers/client_provider.dart';
import '../../../data/models/invoice_model.dart';
import 'add_invoice_screen.dart';
import 'add_client_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<DashboardProvider>().refresh();
            await context.read<InvoiceProvider>().loadInvoices();
            await context.read<ClientProvider>().loadClients();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 20.h),
                _buildStatsCards(context),
                SizedBox(height: 20.h),
                _buildQuickActions(context),
                SizedBox(height: 20.h),
                _buildRecentInvoices(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.greeting + '! 🙏',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    provider.userName.isNotEmpty
                        ? provider.userName
                        : 'Welcome back',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (provider.businessName.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      provider.businessName,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 24.sp),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Consumer2<InvoiceProvider, ClientProvider>(
      builder: (context, invProv, clientProv, _) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Total Revenue',
                    value: '₹${_formatAmount(invProv.totalRevenue)}',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF059669),
                    bgColor: const Color(0xFFECFDF5),
                    isLoading: invProv.isLoading,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _statCard(
                    title: 'Outstanding',
                    value: '₹${_formatAmount(invProv.outstandingAmount)}',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFDC2626),
                    bgColor: const Color(0xFFFEF2F2),
                    isLoading: invProv.isLoading,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Total Invoices',
                    value: '${invProv.totalInvoices}',
                    icon: Icons.receipt_outlined,
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF5F3FF),
                    isLoading: invProv.isLoading,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _statCard(
                    title: 'Clients',
                    value: '${clientProv.totalClients}',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF0891B2),
                    bgColor: const Color(0xFFECFEFF),
                    isLoading: clientProv.isLoading,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isLoading,
  }) {
    return Container(
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
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          if (isLoading)
            Container(
              height: 22.h,
              width: 70.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6.r),
              ),
            )
          else
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.add_circle_outline_rounded,
                label: 'New Invoice',
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddInvoiceScreen()),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _actionButton(
                icon: Icons.person_add_outlined,
                label: 'Add Client',
                color: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddClientScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
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
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 24.sp, color: color),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInvoices(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Invoices',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (provider.allInvoices.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // Switch to Invoices tab via parent HomeScreen
                    },
                    child: Text(
                      'See All',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.recentInvoices.isEmpty)
              _emptyInvoicesCard(context)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.recentInvoices.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (_, index) =>
                    _invoiceTile(provider.recentInvoices[index]),
              ),
          ],
        );
      },
    );
  }

  Widget _emptyInvoicesCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'No invoices yet',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Create your first invoice to get started',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddInvoiceScreen()),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceTile(InvoiceModel invoice) {
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final date =
        '${months[invoice.issueDate.month - 1]} ${invoice.issueDate.day}';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.receipt_outlined,
                color: const Color(0xFF2563EB), size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.clientName,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${invoice.invoiceNumber} • $date',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_formatAmount(invoice.amount)}',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusBg[invoice.status] ?? const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  invoice.status,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColors[invoice.status] ??
                        const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      final formatted = amount.toStringAsFixed(0);
      return formatted.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return amount.toStringAsFixed(2);
  }
}