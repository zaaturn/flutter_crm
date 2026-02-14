import 'package:flutter/material.dart';

class InvoiceActionButtons extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final bool isLoading;

  const InvoiceActionButtons({
    super.key,
    required this.onShare,
    required this.onDownload,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // SaaS Secondary Button (Share)
            Expanded(
              flex: 1,
              child: _ModernButton(
                onPressed: isLoading ? null : onShare,
                icon: Icons.share_rounded,
                label: "Share",
                isOutlined: true,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: 16),

            // SaaS Primary Button (Download)
            Expanded(
              flex: 2,
              child: _ModernButton(
                onPressed: isLoading ? null : onDownload,
                icon: Icons.file_download_outlined,
                label: "Download PDF",
                isOutlined: false,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isOutlined;
  final bool isLoading;

  const _ModernButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isOutlined,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    const Color primaryColor = Color(0xFF4F46E5); // Indigo 600

    // Outlined Button Style (Share)
    if (isOutlined) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDisabled ? Colors.grey.shade200 : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          color: Colors.white,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isDisabled ? Colors.grey.shade400 : const Color(0xFF374151),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDisabled ? Colors.grey.shade400 : const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Filled Button Style (Download)
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isDisabled
            ? null
            : const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        color: isDisabled ? Colors.grey.shade300 : null,
        boxShadow: isDisabled
            ? null
            : [
          BoxShadow(
            color: primaryColor.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show Spinner if loading, otherwise show Icon
              isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                isLoading ? "Processing..." : label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}