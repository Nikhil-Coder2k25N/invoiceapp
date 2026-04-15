import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import 'invoices_screen.dart';
import 'clients_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isNavVisible = true;
  double _lastScrollOffset = 0;

  late final AnimationController _navController;
  late final Animation<Offset> _navSlide;

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(
        Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Invoices'),
    _NavItem(Icons.people_outline_rounded, Icons.people_rounded, 'Clients'),
    _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _navSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5), // slide down off screen
    ).animate(CurvedAnimation(
      parent: _navController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      const threshold = 8.0; // ignore tiny jitter

      if (delta > threshold && _isNavVisible) {
        // Scrolling DOWN → hide nav
        setState(() => _isNavVisible = false);
        _navController.forward();
      } else if (delta < -threshold && !_isNavVisible) {
        // Scrolling UP → show nav
        setState(() => _isNavVisible = true);
        _navController.reverse();
      }
      _lastScrollOffset = notification.metrics.pixels;
    }

    // Always show nav when reaching top or near bottom
    if (notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      if (metrics.pixels <= 0 && !_isNavVisible) {
        setState(() => _isNavVisible = true);
        _navController.reverse();
      }
    }
  }

  List<Widget> get _screens => [
        const DashboardScreen(),
        const InvoicesScreen(),
        const ClientsScreen(),
        const SettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // body extends behind the transparent nav
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScrollNotification(notification);
          return false; // let the notification keep bubbling
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: SlideTransition(
        position: _navSlide,
        child: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          child: Row(
            children: List.generate(
              _navItems.length,
              (index) => Expanded(child: _buildNavItem(index)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _selectedIndex = index);
        if (!_isNavVisible) {
          setState(() => _isNavVisible = true);
          _navController.reverse();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pill indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: isSelected ? 60.w : 42.w,
            height: 34.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(17.r),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey('${item.label}_$isSelected'),
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF94A3B8),
                  size: 24.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF94A3B8),
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}