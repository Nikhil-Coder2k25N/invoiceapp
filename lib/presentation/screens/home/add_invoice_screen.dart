import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/client_provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/client_model.dart';
import '../../../core/services/pdf_invoice_service.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  ClientModel? _selectedClient;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  double _gstRate = 18.0;
  String _status = 'PENDING';
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  bool _invoiceCreated = false;
  String? _createdInvoiceId;

  final List<double> _gstRates = [0.0, 5.0, 12.0, 18.0, 28.0];
  final List<String> _statuses = ['PENDING', 'PAID', 'OVERDUE'];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isIssue) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isIssue ? _issueDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isIssue) {
          _issueDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _createInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      _showSnackbar('Please select a client before creating the invoice.', false);
      return;
    }
    setState(() => _isLoading = true);

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final provider = context.read<InvoiceProvider>();

    final success = await provider.addInvoice(
      clientId: _selectedClient!.id,
      clientName: _selectedClient!.name,
      amount: amount,
      gstRate: _gstRate,
      issueDate: _issueDate,
      dueDate: _dueDate,
      status: _status,
      notes: _notesController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      if (success) {
        _invoiceCreated = true;
        _createdInvoiceId = provider.allInvoices.isNotEmpty
            ? provider.allInvoices.first.id
            : null;
      }
    });

    if (success) {
      _showSnackbar('Invoice created successfully!', true);
    } else {
      _showSnackbar(
          provider.error ?? 'Failed to create invoice. Please try again.', false);
    }
  }

  Future<void> _downloadPdf() async {
    final provider = context.read<InvoiceProvider>();
    final auth = context.read<AuthProvider>();
    final invoice = _createdInvoiceId != null
        ? provider.allInvoices.firstWhere(
            (i) => i.id == _createdInvoiceId,
            orElse: () => provider.allInvoices.first,
          )
        : provider.allInvoices.first;

    await PdfInvoiceService.printOrDownloadInvoice(
      context: context,
      invoice: invoice,
      businessOwner: auth.currentUser,
    );
  }

  void _showSnackbar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor:
            isSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final gstAmt = amount * (_gstRate / 100);
    final totalAmt = amount + gstAmt;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('New Invoice',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── SUCCESS BANNER (after invoice is created) ──
              if (_invoiceCreated) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFF6EE7B7)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, color: Colors.white, size: 16.sp),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invoice Created!',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                    color: const Color(0xFF064E3B),
                                  ),
                                ),
                                Text(
                                  'Your invoice has been saved successfully.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _downloadPdf,
                              icon: const Icon(Icons.picture_as_pdf_outlined,
                                  size: 18),
                              label: Text('Download PDF',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF059669),
                                side: const BorderSide(color: Color(0xFF059669)),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded, size: 18),
                              label: Text('Go Back',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // ── CLIENT SELECTION ────────────────────────────
              _sectionCard(
                title: 'Select Client',
                icon: Icons.people_alt_outlined,
                color: const Color(0xFF2563EB),
                child: Consumer<ClientProvider>(
                  builder: (context, clientProv, _) {
                    if (clientProv.clients.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFD97706)),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'No clients found. Please add a client first.',
                                style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF92400E)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return DropdownButtonFormField<ClientModel>(
                      value: _selectedClient,
                      hint: Text('Select a registered client',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFCBD5E1), fontSize: 14.sp)),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline,
                            color: Color(0xFF64748B)),
                      ),
                      items: clientProv.clients.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(
                            c.company?.isNotEmpty == true
                                ? '${c.name}  ·  ${c.company}'
                                : c.name,
                            style: GoogleFonts.inter(fontSize: 14.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _invoiceCreated
                          ? null
                          : (c) => setState(() => _selectedClient = c),
                      validator: (v) =>
                          v == null ? 'Please select a client.' : null,
                    );
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // ── INVOICE DETAILS ─────────────────────────────
              _sectionCard(
                title: 'Invoice Details',
                icon: Icons.receipt_outlined,
                color: const Color(0xFF7C3AED),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Invoice Amount (₹) *'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _amountController,
                      enabled: !_invoiceCreated,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'e.g. 25000.00',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                        prefixIcon: const Icon(Icons.currency_rupee,
                            color: Color(0xFF64748B)),
                        helperText: 'Enter base amount before applying GST.',
                        helperStyle: GoogleFonts.inter(fontSize: 11.sp),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Invoice amount is required.';
                        }
                        final parsed = double.tryParse(v.trim());
                        if (parsed == null) return 'Please enter a valid number.';
                        if (parsed <= 0) return 'Amount must be greater than zero.';
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    _buildLabel('Applicable GST Rate'),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _gstRates.map((rate) {
                          final isSelected = _gstRate == rate;
                          return Expanded(
                            child: GestureDetector(
                              onTap: _invoiceCreated
                                  ? null
                                  : () => setState(() => _gstRate = rate),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.symmetric(
                                    vertical: 4.h, horizontal: 3.w),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    '${rate.toInt()}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Live GST calculation preview
                    if (amount > 0) ...[
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          children: [
                            _calcRow('Base Amount',
                                '₹ ${amount.toStringAsFixed(2)}'),
                            if (_gstRate > 0) ...[
                              SizedBox(height: 6.h),
                              _calcRow(
                                  'GST @ ${_gstRate.toInt()}%',
                                  '+ ₹ ${gstAmt.toStringAsFixed(2)}',
                                  color: const Color(0xFF7C3AED)),
                            ],
                            Divider(
                                height: 16,
                                color: const Color(0xFFBFDBFE),
                                thickness: 1),
                            _calcRow(
                              'Grand Total',
                              '₹ ${totalAmt.toStringAsFixed(2)}',
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 20.h),

                    _buildLabel('Invoice Status'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.flag_outlined,
                            color: Color(0xFF64748B)),
                        helperText: 'Set to "Pending" if payment is yet to be received.',
                        helperStyle: GoogleFonts.inter(fontSize: 11.sp),
                      ),
                      items: _statuses.map((s) {
                        final colors = {
                          'PAID': const Color(0xFF059669),
                          'PENDING': const Color(0xFFD97706),
                          'OVERDUE': const Color(0xFFDC2626),
                        };
                        return DropdownMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: colors[s],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(s, style: GoogleFonts.inter()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _invoiceCreated
                          ? null
                          : (v) => setState(() => _status = v!),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ── DATES ───────────────────────────────────────
              _sectionCard(
                title: 'Invoice Dates',
                icon: Icons.calendar_month_outlined,
                color: const Color(0xFF0891B2),
                child: Column(
                  children: [
                    _datePicker(
                      label: 'Issue Date',
                      hint: 'Date of invoice generation',
                      date: _issueDate,
                      months: months,
                      onTap: _invoiceCreated ? () {} : () => _pickDate(true),
                    ),
                    SizedBox(height: 12.h),
                    _datePicker(
                      label: 'Payment Due Date',
                      hint: 'Date by which payment is due',
                      date: _dueDate,
                      months: months,
                      onTap: _invoiceCreated ? () {} : () => _pickDate(false),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ── NOTES ───────────────────────────────────────
              _sectionCard(
                title: 'Additional Notes',
                icon: Icons.notes_outlined,
                color: const Color(0xFF64748B),
                child: TextFormField(
                  controller: _notesController,
                  enabled: !_invoiceCreated,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Payment to be made via NEFT/RTGS to account details provided separately. Late payments attract 2% monthly interest.',
                    hintStyle: GoogleFonts.inter(
                        color: const Color(0xFFCBD5E1), fontSize: 12.sp),
                    border: const OutlineInputBorder(),
                    helperText: 'Optional – include payment terms, bank details, or any instructions.',
                    helperStyle: GoogleFonts.inter(fontSize: 11.sp),
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              // ── ACTION BUTTONS ──────────────────────────────
              if (!_invoiceCreated) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createInvoice,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _isLoading ? 'Creating Invoice…' : 'Create Invoice',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // After creation: show download / print button prominently
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: _downloadPdf,
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: Text(
                      'Print / Download PDF',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Widget helpers ─────────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 16.sp, color: color),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20, indent: 16, endIndent: 16),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required String hint,
    required DateTime date,
    required List<String> months,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF64748B), size: 18),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                        fontSize: 11.sp, color: const Color(0xFF94A3B8)),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${months[date.month - 1]} ${date.day}, ${date.year}',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    hint,
                    style: GoogleFonts.inter(
                        fontSize: 10.sp, color: const Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _calcRow(String label, String value,
      {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: bold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: bold ? 15.sp : 13.sp,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color ?? (bold ? const Color(0xFF1E293B) : const Color(0xFF374151)),
          ),
        ),
      ],
    );
  }
}
