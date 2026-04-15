import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/client_provider.dart';
import '../../../data/models/client_model.dart';

class AddClientScreen extends StatefulWidget {
  final ClientModel? existingClient;
  const AddClientScreen({super.key, this.existingClient});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.existingClient != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.existingClient!;
      _nameController.text = c.name;
      _emailController.text = c.email;
      _phoneController.text = c.phone ?? '';
      _companyController.text = c.company ?? '';
      _addressController.text = c.address ?? '';
      _gstinController.text = c.gstin ?? '';
      _panController.text = c.pan ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = context.read<ClientProvider>();
    bool success;

    if (_isEditing) {
      final updated = widget.existingClient!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        company: _companyController.text.trim(),
        address: _addressController.text.trim(),
        gstin: _gstinController.text.trim().toUpperCase(),
        pan: _panController.text.trim().toUpperCase(),
      );
      success = await provider.updateClient(updated);
    } else {
      success = await provider.addClient(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        company: _companyController.text.trim(),
        address: _addressController.text.trim(),
        gstin: _gstinController.text.trim().toUpperCase(),
        pan: _panController.text.trim().toUpperCase(),
      );
    }

    setState(() => _isLoading = false);
    if (!mounted) return;

    _showSnackbar(
      message: success
          ? (_isEditing
              ? 'Client updated successfully.'
              : 'Client added successfully.')
          : (provider.error ?? 'Failed to save client. Please try again.'),
      isSuccess: success,
    );
    if (success) Navigator.pop(context);
  }

  void _showSnackbar({required String message, required bool isSuccess}) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Client' : 'Add New Client',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
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
              // Basic Info
              _sectionCard(
                title: 'Contact Information',
                icon: Icons.person_outline,
                color: const Color(0xFF2563EB),
                child: Column(
                  children: [
                    _buildLabel('Full Name *'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'e.g. Nikhil Singh Bhati',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                        prefixIcon: const Icon(Icons.person_outline,
                            color: Color(0xFF64748B)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Client name is required.'
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Email Address *'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'e.g. contact@business.com',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF64748B)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email address is required.';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Mobile Number'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: '10-digit mobile number',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                        prefixText: '+91  ',
                        prefixStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151)),
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: Color(0xFF64748B)),
                        counterText: '',
                      ),
                      validator: (v) {
                        if (v != null &&
                            v.trim().isNotEmpty &&
                            v.trim().length != 10) {
                          return 'Mobile number must be exactly 10 digits.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Business Info
              _sectionCard(
                title: 'Business Information',
                icon: Icons.business_outlined,
                color: const Color(0xFF7C3AED),
                child: Column(
                  children: [
                    _buildLabel('Company / Firm Name'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _companyController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'e.g. ABC Trading Co. Pvt. Ltd.',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                        prefixIcon: const Icon(Icons.business_outlined,
                            color: Color(0xFF64748B)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Business Address'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Plot No. 12, MIDC Industrial Area,\nMumbai – 400 093',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                        prefixIcon: const Icon(Icons.location_on_outlined,
                            color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // GST / Tax Info
              _sectionCard(
                title: 'GST & Tax Details',
                icon: Icons.account_balance_outlined,
                color: const Color(0xFF059669),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFFD97706), size: 16),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Required for generating GST-compliant invoices.',
                              style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF92400E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('GSTIN (Goods & Services Tax ID)'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _gstinController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 15,
                      decoration: InputDecoration(
                        hintText: 'Format: 22AAAAA0000A1Z5',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                        prefixIcon: const Icon(Icons.receipt_outlined,
                            color: Color(0xFF64748B)),
                        counterText: '',
                        helperText:
                            '15-character alphanumeric GST Identification Number',
                        helperStyle: GoogleFonts.inter(fontSize: 11.sp),
                      ),
                      validator: (v) {
                        if (v != null &&
                            v.trim().isNotEmpty &&
                            v.trim().length != 15) {
                          return 'GSTIN must be exactly 15 characters.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('PAN (Permanent Account Number)'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _panController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: 'Format: AAAPL1234C',
                        hintStyle:
                            GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                        prefixIcon: const Icon(Icons.credit_card_outlined,
                            color: Color(0xFF64748B)),
                        counterText: '',
                        helperText:
                            '10-character alphanumeric PAN issued by Income Tax Dept.',
                        helperStyle: GoogleFonts.inter(fontSize: 11.sp),
                      ),
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          if (v.trim().length != 10) {
                            return 'PAN must be exactly 10 characters.';
                          }
                          if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
                              .hasMatch(v.trim())) {
                            return 'Invalid PAN format. Expected: AAAPL1234C';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isEditing
                                ? Icons.save_outlined
                                : Icons.person_add_outlined),
                            SizedBox(width: 8.w),
                            Text(
                              _isEditing ? 'Update Client' : 'Save Client',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

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
}
