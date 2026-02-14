import 'package:flutter/material.dart';
import '../model/lead_model.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;

  const LeadCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lead.dealName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  lead.priority,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // company
            Text(
              lead.companyName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            // buttons row
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined, color: Colors.black54),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_outlined, color: Colors.black54),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
