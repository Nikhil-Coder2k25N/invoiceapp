import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

const List<String> indianStates = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
  'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
  'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
  'West Bengal', 'Delhi', 'Jammu & Kashmir', 'Ladakh',
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _businessController;
  late TextEditingController _gstinController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _selectedState;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _businessController =
        TextEditingController(text: user?.businessName ?? '');
    _gstinController = TextEditingController(text: user?.gstin ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _selectedState = user?.state;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _gstinController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await context.read<AuthProvider>().updateProfile(
          fullName: _nameController.text.trim(),
          businessName: _businessController.text.trim(),
          gstin: _gstinController.text.trim().toUpperCase(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          state: _selectedState,
        );
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Profile updated successfully!' : 'Failed to update profile',
          style: GoogleFonts.inter(),
        ),
        backgroundColor:
            success ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Profile & Business',
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
              _sectionCard(
                title: 'Personal Information',
                icon: Icons.person_outline,
                color: const Color(0xFF2563EB),
                child: Column(
                  children: [
                    _buildLabel('Full Name *'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Rahul Sharma',
                        prefixIcon: Icon(Icons.person_outline,
                            color: Color(0xFF64748B)),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter your name' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Mobile Number'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '9876543210',
                        prefixText: '+91  ',
                        prefixIcon: Icon(Icons.phone_outlined,
                            color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              _sectionCard(
                title: 'Business Details',
                icon: Icons.business_outlined,
                color: const Color(0xFF059669),
                child: Column(
                  children: [
                    _buildLabel('Business / Firm Name'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _businessController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Sharma Enterprises',
                        prefixIcon: Icon(Icons.business_outlined,
                            color: Color(0xFF64748B)),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    _buildLabel('GSTIN'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _gstinController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 15,
                      decoration: const InputDecoration(
                        hintText: '27AAPFU0939F1ZV',
                        prefixIcon: Icon(Icons.receipt_outlined,
                            color: Color(0xFF64748B)),
                        counterText: '',
                      ),
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length != 15) {
                          return 'GSTIN must be 15 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    _buildLabel('Business Address'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Shop No. 5, MG Road, Pune - 411001',
                        prefixIcon: Icon(Icons.location_on_outlined,
                            color: Color(0xFF64748B)),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    _buildLabel('State'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      hint: Text('Select state',
                          style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8))),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.map_outlined,
                            color: Color(0xFF64748B)),
                      ),
                      items: indianStates
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, style: GoogleFonts.inter())))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedState = v),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
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
                            const Icon(Icons.save_outlined),
                            SizedBox(width: 8.w),
                            Text(
                              'Save Profile',
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
            color: Colors.black.withOpacity(0.04),
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
                Icon(icon, size: 18.sp, color: color),
                SizedBox(width: 8.w),
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
          const Divider(height: 16, indent: 16, endIndent: 16),
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
