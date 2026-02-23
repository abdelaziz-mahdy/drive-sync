import 'package:flutter/material.dart';

enum EditorSection {
  basic(icon: Icons.person_outline, label: 'Basic'),
  mode(icon: Icons.sync, label: 'Mode'),
  paths(icon: Icons.folder, label: 'Paths'),
  filters(icon: Icons.filter_list, label: 'Filters'),
  excludes(icon: Icons.block, label: 'Excludes'),
  advanced(icon: Icons.tune, label: 'Advanced');

  const EditorSection({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
