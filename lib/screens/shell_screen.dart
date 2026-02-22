import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profiles_provider.dart';
import '../providers/sync_scheduler_provider.dart';
import '../widgets/sidebar_layout.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/status_indicator.dart';
import 'activity/activity_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'profile_editor/profile_editor_screen.dart';
import 'settings/settings_screen.dart';

/// The navigation items available in the sidebar.
enum NavItem {
  dashboard(icon: Icons.dashboard, label: 'Dashboard'),
  activity(icon: Icons.history, label: 'Activity'),
  settings(icon: Icons.settings, label: 'Settings');

  const NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

// ---------------------------------------------------------------------------
// Intent classes for keyboard shortcuts
// ---------------------------------------------------------------------------

/// Intent to create a new sync profile.
class NewProfileIntent extends Intent {
  const NewProfileIntent();
}

/// Intent to navigate back / close a dialog.
class GoBackIntent extends Intent {
  const GoBackIntent();
}

/// Main shell screen that provides sidebar navigation and content switching.
class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  NavItem _selectedItem = NavItem.dashboard;

  void _openNewProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileEditorScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep the scheduler alive so timers fire while the app is open.
    ref.watch(syncSchedulerProvider);
    final profilesAsync = ref.watch(profilesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyN, meta: Platform.isMacOS, control: !Platform.isMacOS):
            const NewProfileIntent(),
        const SingleActivator(LogicalKeyboardKey.escape):
            const GoBackIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          NewProfileIntent: CallbackAction<NewProfileIntent>(
            onInvoke: (_) {
              _openNewProfile();
              return null;
            },
          ),
          GoBackIntent: CallbackAction<GoBackIntent>(
            onInvoke: (_) {
              // Pop the top route if possible, otherwise do nothing.
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: SidebarLayout(
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'No profiles yet',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: profiles.length,
                          itemBuilder: (context, index) {
                            final profile = profiles[index];
                            final status =
                                StatusIndicator.fromProfile(profile);
                            return ListTile(
                              dense: true,
                              leading:
                                  StatusIndicator(status: status, size: 10),
                              title: Text(
                                profile.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProfileEditorScreen(profile: profile),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      loading: () => SkeletonLoader(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              3,
                              (_) => const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: SkeletonLine(
                                    height: 32, borderRadius: 8),
                              ),
                            ),
                          ),
                        ),
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
            content: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedItem) {
      case NavItem.dashboard:
        return const DashboardScreen(key: ValueKey('dashboard'));
      case NavItem.activity:
        return const ActivityScreen(key: ValueKey('activity'));
      case NavItem.settings:
        return const SettingsScreen(key: ValueKey('settings'));
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
