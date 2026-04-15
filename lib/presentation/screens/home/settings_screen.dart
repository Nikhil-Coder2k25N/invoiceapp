import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Settings',
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
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.currentUser;
          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            children: [
              // Profile Card
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          (user?.fullName ?? 'U')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'User',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (user?.businessName != null &&
                                user!.businessName!.isNotEmpty)
                              Text(
                                user.businessName!,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            Text(
                              user?.email ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              _buildSectionTitle('Account'),
              SizedBox(height: 8.h),
              _buildSettingsCard([
                _buildTile(
                  icon: Icons.person_outline,
                  title: 'Profile & Business',
                  subtitle: 'Name, business details, GSTIN',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.account_balance_outlined,
                  title: 'Tax Settings',
                  subtitle: 'GST configuration, tax rates',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Coming soon!', style: GoogleFonts.inter()),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ]),

              SizedBox(height: 20.h),

              _buildSectionTitle('Preferences'),
              SizedBox(height: 8.h),
              _buildSettingsCard([
                _buildTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English (India)',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.currency_rupee,
                  title: 'Currency',
                  subtitle: 'Indian Rupee (₹ INR)',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Payment reminders, overdue alerts',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Coming soon!', style: GoogleFonts.inter()),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ]),

              SizedBox(height: 20.h),

              _buildSectionTitle('Support'),
              SizedBox(height: 8.h),
              _buildSettingsCard([
                _buildTile(
                  icon: Icons.help_outline,
                  title: 'Help & FAQ',
                  subtitle: 'Get help with the app',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.info_outline,
                  title: 'About Invoice Pro',
                  subtitle: 'Version 1.0.0 • GST-ready for India',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Invoice Pro',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        '© 2024 Invoice Pro India\nGST compliant invoicing solution',
                  ),
                ),
              ]),

              SizedBox(height: 20.h),

              // Sign Out Button
              Container(
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
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: Colors.red, size: 20),
                  ),
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'You will be logged out of the app',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: Colors.grey.shade500),
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.red),
                  onTap: () => _confirmSignOut(context, auth),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          );
        },
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Sign Out',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Sign Out', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
            fontSize: 12.sp, color: const Color(0xFF64748B)),
      ),
      trailing: Icon(Icons.chevron_right,
          color: Colors.grey.shade400, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 60,
      endIndent: 0,
      color: Color(0xFFF1F5F9),
    );
  }
}