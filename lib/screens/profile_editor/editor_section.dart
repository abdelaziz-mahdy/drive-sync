import 'package:flutter/material.dart';

enum EditorSection {
  general(icon: Icons.folder, label: 'General'),
  mode(icon: Icons.sync, label: 'Mode'),
  filters(icon: Icons.filter_list, label: 'Filters'),
  advanced(icon: Icons.tune, label: 'Advanced');

  const EditorSection({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
