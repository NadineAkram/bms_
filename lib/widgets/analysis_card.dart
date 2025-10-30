import 'package:flutter/material.dart';

/// A reusable, stylized card widget used to display summary information and status.
class AnalysisCard extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Color color;
  final String description;
  final Widget? contentWidget;

  const AnalysisCard({
    super.key,
    required this.title,
    required this.status,
    required this.icon,
    required this.color,
    required this.description,
    this.contentWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (contentWidget != null) ...[
            const SizedBox(height: 12),
            contentWidget!,
          ],
        ],
      ),
    );
  }
}
