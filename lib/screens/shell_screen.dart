import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profiles_provider.dart';
import '../widgets/sidebar_layout.dart';
import '../widgets/status_indicator.dart';
import 'dashboard/dashboard_screen.dart';

/// The navigation items available in the sidebar.
enum NavItem {
  dashboard(icon: Icons.dashboard, label: 'Dashboard'),
  activity(icon: Icons.history, label: 'Activity'),
  settings(icon: Icons.settings, label: 'Settings');

  const NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Main shell screen that provides sidebar navigation and content switching.
class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  NavItem _selectedItem = NavItem.dashboard;

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profilesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SidebarLayout(
      sidebar: Material(
        color: colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'DriveSync',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Navigation items
            for (final item in NavItem.values)
              _NavTile(
                icon: item.icon,
                label: item.label,
                selected: _selectedItem == item,
                onTap: () => setState(() => _selectedItem = item),
              ),

            const Divider(indent: 16, endIndent: 16),

            // Profiles section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'PROFILES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Profile list
            Expanded(
              child: profilesAsync.when(
                data: (profiles) {
                  if (profiles.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'No profiles yet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      final status =
                          StatusIndicator.fromProfile(profile);
                      return ListTile(
                        dense: true,
                        leading: StatusIndicator(status: status, size: 10),
                        title: Text(
                          profile.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () {
                          // Navigate to dashboard and potentially highlight profile
                          setState(() => _selectedItem = NavItem.dashboard);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error loading profiles',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_selectedItem) {
      case NavItem.dashboard:
        return const DashboardScreen();
      case NavItem.activity:
        return const Center(child: Text('Activity'));
      case NavItem.settings:
        return const Center(child: Text('Settings'));
    }
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: selected ? colorScheme.primary : colorScheme.onSurface,
          size: 22,
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? colorScheme.primary : colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
      ),
    );
  }
}
