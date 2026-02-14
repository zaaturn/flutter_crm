import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lead_bloc.dart';
import '../bloc/lead_state.dart';
import '../model/lead_model.dart';


class AssignLeadScreen extends StatefulWidget {
  const AssignLeadScreen({super.key});

  @override
  State<AssignLeadScreen> createState() => _AssignLeadScreenState();
}

class _AssignLeadScreenState extends State<AssignLeadScreen> {
  String? selectedEmployee;
  Lead? selectedLead;
  String selectedPriority = "Medium";
  DateTime? endDate;

  final priorities = ["High", "Medium", "Low"];

  /// STATIC EMPLOYEE LIST FOR NOW
  final employees = [
    "Sumantha HM",
    "Rahul",
    "Priya",
    "Manoj",
    "Sneha",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Assign Lead"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<LeadBloc, LeadState>(
          builder: (context, state) {
            if (state is! LeadLoaded) {
              return const Center(
                child: Text(
                  "No leads available",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              );
            }

            return ListView(
              children: [
                // EMPLOYEE DROPDOWN
                _buildDropdown(
                  title: "Assign to Employee",
                  value: selectedEmployee,
                  items: employees,
                  onChanged: (value) {
                    setState(() => selectedEmployee = value);
                  },
                ),

                const SizedBox(height: 20),

                // LEAD DROPDOWN
                _buildDropdown(
                  title: "Select Lead",
                  value: selectedLead?.dealName,
                  items: state.leads.map((e) => e.dealName).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLead = state.leads.firstWhere(
                            (l) => l.dealName == value,
                      );
                    });
                  },
                ),

                const SizedBox(height: 20),

                // PRIORITY DROPDOWN
                _buildDropdown(
                  title: "Priority",
                  value: selectedPriority,
                  items: priorities,
                  onChanged: (value) {
                    setState(() => selectedPriority = value!);
                  },
                ),

                const SizedBox(height: 20),

                // DATE PICKER
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: DateTime.now().add(const Duration(days: 5)),
                    );

                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    endDate == null
                        ? "Select End Date"
                        : "End Date: ${endDate!.toLocal().toString().split(' ')[0]}",
                  ),
                ),

                const SizedBox(height: 50),

                // ASSIGN BUTTON
                ElevatedButton(
                  onPressed: () {
                    if (selectedEmployee == null ||
                        selectedLead == null ||
                        endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please complete all fields"),
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lead assigned successfully!"),
                      ),
                    );

                    // Reset all fields
                    setState(() {
                      selectedEmployee = null;
                      selectedLead = null;
                      endDate = null;
                      selectedPriority = "Medium";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Assign Lead",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // REUSABLE DROPDOWN
  Widget _buildDropdown({
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: const Text("Select"),
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

