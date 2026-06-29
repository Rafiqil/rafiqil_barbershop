import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../customers/customers_screen.dart';
import '../services/services_screen.dart';
import '../transactions/transactions_screen.dart';
import '../schedules/schedules_screen.dart';
import 'dashboard_screen.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem(this.label, this.icon, this.activeIcon);
}

const _navItems = <_NavItem>[
  _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard),
  _NavItem('Pelanggan', Icons.people_outline, Icons.people),
  _NavItem('Layanan', Icons.content_cut_outlined, Icons.content_cut),
  _NavItem('Transaksi', Icons.receipt_long_outlined, Icons.receipt_long),
  _NavItem('Jadwal', Icons.calendar_today_outlined, Icons.calendar_today),
];

/// Kerangka utama aplikasi: sidebar di desktop/tablet, bottom-nav di mobile.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    CustomersScreen(),
    ServicesScreen(),
    TransactionsScreen(),
    SchedulesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final isMedium = width >= 640 && width < 900;

    if (isWide || isMedium) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(
              index: _index,
              expanded: isWide,
              onSelect: (i) => setState(() => _index = i),
            ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(title: _navItems[_index].label),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: KeyedSubtree(
                        key: ValueKey(_index),
                        child: _pages[_index],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile: AppBar + bottom navigation.
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const _Logo(size: 30),
            const SizedBox(width: 10),
            Text(_navItems[_index].label),
          ],
        ),
        actions: const [_ProfileMenu(), SizedBox(width: 8)],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accentSoft.withOpacity(.5),
        destinations: _navItems
            .map((n) => NavigationDestination(
                  icon: Icon(n.icon),
                  selectedIcon: Icon(n.activeIcon, color: AppColors.primary),
                  label: n.label,
                ))
            .toList(),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int index;
  final bool expanded;
  final ValueChanged<int> onSelect;
  const _Sidebar({
    required this.index,
    required this.expanded,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Container(
      width: expanded ? 256 : 80,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: expanded ? 20 : 0, vertical: 24),
            child: Row(
              mainAxisAlignment:
                  expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                const _Logo(size: 38),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rafiqil',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Text('Barbershop',
                            style: TextStyle(
                                color: AppColors.accentSoft, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8),
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final active = i == index;
                final item = _navItems[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: active
                        ? AppColors.sidebarActive
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onSelect(i),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: expanded ? 14 : 0, vertical: 13),
                        child: Row(
                          mainAxisAlignment: expanded
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            Icon(active ? item.activeIcon : item.icon,
                                size: 21,
                                color: active
                                    ? AppColors.accent
                                    : Colors.white70),
                            if (expanded) ...[
                              const SizedBox(width: 14),
                              Text(item.label,
                                  style: TextStyle(
                                    color:
                                        active ? Colors.white : Colors.white70,
                                    fontWeight: active
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 14,
                                  )),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.sidebarActive,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        Formatters.inisial(user?.name ?? 'R'),
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.name ?? 'Rafiqil',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(user?.role ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Keluar',
                      onPressed: () => _confirmLogout(context),
                      icon: const Icon(Icons.logout,
                          color: Colors.white70, size: 18),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IconButton(
                tooltip: 'Keluar',
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout, color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const Spacer(),
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Belum ada notifikasi baru.')));
            },
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 4),
          const _ProfileMenu(),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return PopupMenuButton<String>(
      tooltip: 'Profil',
      offset: const Offset(0, 48),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) {
        if (v == 'logout') _confirmLogout(context);
        if (v == 'profile') _showProfile(context);
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.name ?? 'Rafiqil',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(user?.email ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'profile',
            child: Row(children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 10),
              Text('Profil Toko')
            ])),
        const PopupMenuItem(
            value: 'logout',
            child: Row(children: [
              Icon(Icons.logout, size: 18, color: AppColors.danger),
              SizedBox(width: 10),
              Text('Keluar', style: TextStyle(color: AppColors.danger))
            ])),
      ],
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primary,
        child: Text(
          Formatters.inisial(user?.name ?? 'R'),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final double size;
  const _Logo({this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.content_cut,
          color: AppColors.primaryDark, size: size * 0.55),
    );
  }
}

Future<void> _confirmLogout(BuildContext context) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Keluar dari aplikasi?',
    message: 'Anda akan keluar dari sesi Rafiqil Barbershop.',
    confirmLabel: 'Keluar',
    destructive: true,
  );
  if (ok && context.mounted) {
    context.read<AuthProvider>().logout();
  }
}

void _showProfile(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Profil Toko',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 16),
              _ProfileRow(Icons.store, 'Nama', 'Rafiqil Barbershop'),
              _ProfileRow(Icons.person, 'Pemilik', 'Rafiqil'),
              _ProfileRow(Icons.phone, 'Telepon', '+6282211283036'),
              _ProfileRow(Icons.email, 'Email', 'xrafiqil@gmail.com'),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 12),
          SizedBox(
              width: 70,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13))),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}
