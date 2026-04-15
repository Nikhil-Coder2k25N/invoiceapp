import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSection(
            title: 'Account',
            children: [
              _buildTile(
                icon: Icons.person_outline,
                title: 'Profile Information',
                subtitle: 'Manage your personal details',
                onTap: () {},
              ),
              _buildTile(
                icon: Icons.business_outlined,
                title: 'Business Details',
                subtitle: 'Company name, address',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSection(
            title: 'Preferences',
            children: [
              _buildTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Email and push notifications',
                onTap: () {},
              ),
              _buildTile(
                icon: Icons.color_lens_outlined,
                title: 'Appearance',
                subtitle: 'Light, Dark, or System',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () async {
              final authBox = Hive.box('authBox');
              await authBox.put('isLoggedIn', false);
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: Colors.blue,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20.sp,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}