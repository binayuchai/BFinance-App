import 'package:bfinance/features/settings/helper/section_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/theme_provider.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        children: [
          //theme mode
          SectionLabel('Theme'),
          _ThemeModetile(
            label: 'System Default',
            subtitle: 'Follow system theme',
            icon: Icons.brightness_auto,
            selected: themeProvider.themeMode == ThemeMode.system,
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
          ),
          _ThemeModetile(
            label: 'Light',
            subtitle: 'Use light theme',
            icon: Icons.light_mode,
            selected: themeProvider.themeMode == ThemeMode.light,
            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
          ),
          _ThemeModetile(
            label: 'Dark',
            subtitle: 'Use dark theme',
            icon: Icons.dark_mode,
            selected: themeProvider.themeMode == ThemeMode.dark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
          ),

          //font size
          SectionLabel('Font Size'),
          _FontSizeTile(
            label: 'Small',
            size: 0.85,
            selected: themeProvider.fontSize == 0.85,
            themeProvider: themeProvider,
          ),
          _FontSizeTile(
            label: 'Medium',
            size: 1.0,
            selected: themeProvider.fontSize == 1.0,
            themeProvider: themeProvider,
          ),
          _FontSizeTile(
            label: 'Large',
            size: 1.15,
            selected: themeProvider.fontSize == 1.15,
            themeProvider: themeProvider,
          ),

          //accent color
          SectionLabel('Accent Color'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 22,
              runSpacing: 12,
              children: [
                _ColorOption(
                  color: const Color(0xFF6750A4),
                  themeProvider: themeProvider,
                ), // purple
                _ColorOption(
                  color: const Color(0xFF006874),
                  themeProvider: themeProvider,
                ), // teal
                _ColorOption(
                  color: const Color(0xFF006E1C),
                  themeProvider: themeProvider,
                ), // green
                _ColorOption(
                  color: const Color(0xFFB3261E),
                  themeProvider: themeProvider,
                ), // red
                _ColorOption(
                  color: const Color(0xFF0061A4),
                  themeProvider: themeProvider,
                ), // blue
                _ColorOption(
                  color: const Color(0xFF6B4EFF),
                  themeProvider: themeProvider,
                ), // indigo
                _ColorOption(
                  color: const Color(0xFFB25E02),
                  themeProvider: themeProvider,
                ), // orange
                _ColorOption(
                  color: const Color(0xFF006A60),
                  themeProvider: themeProvider,
                ), // cyan
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//theme mode tile
class _ThemeModetile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap; // Callback for onTap event

  const _ThemeModetile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

//font size tile
class _FontSizeTile extends StatelessWidget {
  final String label;
  final double size;
  final bool selected;
  final ThemeProvider themeProvider;

  const _FontSizeTile({
    required this.label,
    required this.size,
    required this.selected,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.format_size,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(label),
      subtitle: Text(
        '${size.toStringAsFixed(1)} pt',
      ), // display font size in points(ex:1 means after dot 1 decimal point)
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () => themeProvider.setFontSize(size),
    );
  }
}

//color option circle
class _ColorOption extends StatelessWidget {
  final Color color;
  final ThemeProvider themeProvider;
  const _ColorOption({required this.color, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final selected = themeProvider.accentColor == color;
    return GestureDetector(
      onTap: () => themeProvider.setAccentColor(color),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
        ),
        child: selected
            ? Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
