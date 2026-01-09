import 'package:flutter/material.dart';
import '../main.dart';


class IntroPage extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final AppLanguage initialLanguage;
  final void Function(ThemeMode theme, AppLanguage language) onStart;

  const IntroPage({
    super.key,
    required this.initialThemeMode,
    required this.initialLanguage,
    required this.onStart,
  });

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late ThemeMode _selectedTheme;
  late AppLanguage _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.initialThemeMode;
    _selectedLanguage = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = _selectedTheme == ThemeMode.dark;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Theme.of(context).cardColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_florist,
                  size: 54,
                  color: Color(0xFF43A047),
                ),
                const SizedBox(height: 12),

                Text(
                  "Bitki Asistanım",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1B5E20),
                  ),
                ),

                const SizedBox(height: 30),

                // ------------------- THEME SELECTION -------------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Tema Seçimi",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _themeButton(
                      label: "Açık Mod",
                      icon: Icons.light_mode,
                      isSelected: _selectedTheme == ThemeMode.light,
                      onTap: () => setState(() {
                        _selectedTheme = ThemeMode.light;
                      }),
                    ),
                    const SizedBox(width: 14),
                    _themeButton(
                      label: "Koyu Mod",
                      icon: Icons.dark_mode,
                      isSelected: _selectedTheme == ThemeMode.dark,
                      onTap: () => setState(() {
                        _selectedTheme = ThemeMode.dark;
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ------------------- LANGUAGE SELECTION -------------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Dil Seçimi",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _languageButton(
                      label: "Türkçe",
                      code: "TR",
                      isSelected: _selectedLanguage == AppLanguage.tr,
                      onTap: () => setState(() {
                        _selectedLanguage = AppLanguage.tr;
                      }),
                    ),
                    const SizedBox(width: 14),
                    _languageButton(
                      label: "English",
                      code: "EN",
                      isSelected: _selectedLanguage == AppLanguage.en,
                      onTap: () => setState(() {
                        _selectedLanguage = AppLanguage.en;
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ------------------- START BUTTON -------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        widget.onStart(_selectedTheme, _selectedLanguage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF66BB6A)
                          : const Color(0xFF43A047),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _selectedLanguage == AppLanguage.tr
                          ? "Uygulamaya Başla"
                          : "Start App",
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------- BUTTON WIDGETS -------------------

  Widget _themeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF43A047)
                  : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected
                    ? const Color(0xFF43A047)
                    : Colors.grey.shade600,
              ),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageButton({
    required String label,
    required String code,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF43A047)
                  : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                code,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isSelected
                      ? const Color(0xFF43A047)
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
