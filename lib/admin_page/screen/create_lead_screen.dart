import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';
import '../model/lead_model.dart';

// Updated secure storage
import 'package:my_app/services/secure_storage_service.dart';

class CreateLeadScreen extends StatefulWidget {
  static const routeName = "/create-lead";
  const CreateLeadScreen({super.key});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final dealCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final contactedCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final productCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  bool isSaving = false;

  // Stage & Priority Lists
  final List<String> stages = [
    "New",
    "Attempting to Contact",
    "Connected",
    "Needs Analysis",
    "Proposal Sent",
    "Negotiation",
    "Qualified",
    "Won / Converted",
    "Lost",
  ];

  final List<String> priorities = ["High", "Medium", "Low"];

  String selectedStage = "New";
  String selectedPriority = "Medium";

  // Mapping Backend Values
  final Map<String, String> stageMap = {
    "New": "NEW",
    "Attempting to Contact": "ATTEMPTING",
    "Connected": "CONNECTED",
    "Needs Analysis": "ANALYSIS",
    "Proposal Sent": "PROPOSAL",
    "Negotiation": "NEGOTIATION",
    "Qualified": "QUALIFIED",
    "Won / Converted": "WON",
    "Lost": "LOST",
  };

  final Map<String, String> priorityMap = {
    "High": "HIGH",
    "Medium": "MEDIUM",
    "Low": "LOW",
  };

  @override
  void dispose() {
    dealCtrl.dispose();
    companyCtrl.dispose();
    contactedCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    productCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  // ======================================================
  // CREATE LEAD SUBMIT (FIXED & UPDATED)
  // ======================================================
  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final storage = SecureStorageService();
      final userId = await storage.readUserId();

      debugPrint("USER ID FROM SECURE STORAGE: $userId");

      if (userId == null || userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User ID missing — please login again")),
          );
        }
        return;
      }

      // Build Lead Object
      final lead = Lead(
        dealName: dealCtrl.text.trim(),
        companyName: companyCtrl.text.trim(),
        contactedBy: contactedCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        product: productCtrl.text.trim(),
        price: priceCtrl.text.trim(),
        stage: stageMap[selectedStage]!,
        priority: priorityMap[selectedPriority]!,
      );

      // Send BLoC Event
      context.read<LeadBloc>().add(CreateLeadEvent(lead));
    } catch (e) {
      debugPrint("SAVE LEAD ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save lead: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0EA5E9),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text("Create Lead", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: BlocListener<LeadBloc, LeadState>(
        listener: (context, state) {
          if (state is LeadCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Lead created successfully")),
            );
            Navigator.of(context).pop();
          }

          if (state is LeadCreateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: _buildForm(),
        ),
      ),
    );
  }

  // ======================================================
  // FORM
  // ======================================================

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildField("Deal Name", dealCtrl, Icons.label),
          _buildField("Company Name", companyCtrl, Icons.business),

          Row(
            children: [
              Expanded(child: _buildField("Contacted By", contactedCtrl, Icons.person)),
              const SizedBox(width: 12),
              Expanded(child: _buildField("Phone", phoneCtrl, Icons.phone)),
            ],
          ),

          _buildField("Email", emailCtrl, Icons.email),

          Row(
            children: [
              Expanded(child: _buildField("Product", productCtrl, Icons.inventory)),
              const SizedBox(width: 12),
              SizedBox(width: 150, child: _buildField("Price", priceCtrl, Icons.currency_rupee)),
            ],
          ),

          const SizedBox(height: 12),
          _buildChips("Stage", stages, selectedStage, (v) => setState(() => selectedStage = v)),

          const SizedBox(height: 10),
          _buildTogglePriority(),

          const SizedBox(height: 20),
          _buildSaveButton(),

          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // FIELD INPUT
  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // STAGE SELECTOR
  Widget _buildChips(String title, List<String> values, String selected, void Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: values.map((v) {
            return ChoiceChip(
              label: Text(v),
              selected: v == selected,
              onSelected: (_) => onSelected(v),
            );
          }).toList(),
        ),
      ],
    );
  }

  // PRIORITY SELECTOR
  Widget _buildTogglePriority() {
    return Row(
      children: [
        const Text("Priority", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 12),
        ToggleButtons(
          isSelected: priorities.map((p) => p == selectedPriority).toList(),
          onPressed: (i) => setState(() => selectedPriority = priorities[i]),
          borderRadius: BorderRadius.circular(8),
          children: priorities.map((p) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(p),
            );
          }).toList(),
        ),
      ],
    );
  }

  // SAVE BUTTON
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSaving ? null : _onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : const Text(
          "Save Lead",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}











