import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';

class GigCard extends StatelessWidget {
  final String companyName;
  final String role;
  final String time;
  final String
  status; // 'Registered', 'Pending', 'Active', 'Completed', 'Cancelled', 'In Progress'
  final Color logoColor;
  final VoidCallback? onTap;

  const GigCard({
    super.key,
    required this.companyName,
    required this.role,
    required this.time,
    required this.status,
    required this.logoColor,
    this.onTap,
  });

  Color get _statusColor {
    // Ensuring mainly blue/primary theme as requested, avoiding purple
    // But keeping semantic colors for completed/cancelled if needed, or sticking to blue/black
    switch (status.toLowerCase()) {
      case 'registered':
      case 'active':
      case 'in progress':
      case 'pending':
        return AppColors.primary; // Blue
      case 'completed':
        return AppColors.primary; // Blue per user request "maintaining blue"
      case 'cancelled':
        return AppColors
            .primary; // Or maybe red? But user said "maintaining blue" for purple parts.
      // The image shows Cancelled as Purple text on purple bg? No, Cancelled usually red/grey.
      // Image: Cancelled is Purple text on light purple bg.
      // User wants Blue instead of Purple. So Blue it is.
      default:
        return AppColors.primary;
    }
  }

  Color get _statusBgColor {
    return AppColors.primary.withOpacity(0.1); // Light blue background
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: logoColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                companyName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Company Name ... Status Chip ... Arrow (Arrow is strictly rightmost in image?)
                  // In image: [Logo] [Company ..... Chip >]
                  // Actually Arrow is separate? No, arrow is right aligned.
                  Row(
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Row 2: Role
                  Text(
                    role,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary, // Blue
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Row 3: Time . Status text
                  Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12, // Matches image small text
                        ),
                      ),
                      const Text(
                        ' · Status: ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        status, // "Complete", "Registered" etc
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
