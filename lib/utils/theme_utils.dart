import 'package:flutter/material.dart';
import '../core/theme.dart';

class ThemeUtils {
  /// Get high contrast text color for better visibility
  static Color getHighContrastTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white
        : AppTheme.textPrimaryColor;
  }

  /// Get secondary text color with better contrast
  static Color getSecondaryTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white70
        : AppTheme.textSecondaryColor;
  }

  /// Get card background color with proper contrast
  static Color getCardBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  /// Get surface color with proper contrast
  static Color getSurfaceColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : Colors.grey[50]!;
  }

  /// Get border color with proper contrast
  static Color getBorderColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF404040)
        : Colors.grey[300]!;
  }

  /// Create a high contrast text style
  static TextStyle getHighContrastTextStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: getHighContrastTextColor(context),
    );
  }

  /// Create a secondary text style with good contrast
  static TextStyle getSecondaryTextStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: getSecondaryTextColor(context),
    );
  }

  /// Create a card with proper theme colors
  static Widget createThemedCard({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: elevation ?? 2,
      margin: margin,
      color: getCardBackgroundColor(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  /// Create a themed container with proper colors
  static Widget createThemedContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BoxBorder? border,
    BorderRadius? borderRadius,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? getCardBackgroundColor(context),
        border: border ?? Border.all(color: getBorderColor(context)),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  /// Create a themed input decoration
  static InputDecoration createThemedInputDecoration({
    required BuildContext context,
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      filled: true,
      fillColor: getSurfaceColor(context),
      labelStyle: getSecondaryTextStyle(context),
      hintStyle: getSecondaryTextStyle(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: getBorderColor(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: getBorderColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.absentColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// Create a themed dropdown button
  static Widget createThemedDropdown<T>({
    required BuildContext context,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
    String? label,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      hint: hint != null
          ? Text(hint, style: getSecondaryTextStyle(context))
          : null,
      decoration: createThemedInputDecoration(
        context: context,
        labelText: label,
      ),
      dropdownColor: getCardBackgroundColor(context),
      style: getHighContrastTextStyle(context),
    );
  }

  /// Create a themed list tile
  static Widget createThemedListTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    Color? tileColor,
  }) {
    return ListTile(
      title: Text(
        title,
        style: getHighContrastTextStyle(context, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: getSecondaryTextStyle(context))
          : null,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      tileColor: tileColor ?? getCardBackgroundColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Create a themed button
  static Widget createThemedButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, color: textColor ?? AppTheme.primaryColor)
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(color: textColor ?? AppTheme.primaryColor),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: backgroundColor ?? AppTheme.primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, color: textColor ?? Colors.white)
            : const SizedBox.shrink(),
        label: Text(text, style: TextStyle(color: textColor ?? Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  /// Show a themed snackbar
  static void showThemedSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show a themed dialog
  static Future<T?> showThemedDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: getHighContrastTextStyle(context, fontWeight: FontWeight.bold),
        ),
        content: content,
        actions: actions,
        backgroundColor: getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

