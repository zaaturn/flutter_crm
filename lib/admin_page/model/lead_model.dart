class Lead {
  final String dealName;
  final String companyName;
  final String phone;
  final String email;
  final String stage;
  final String priority;
  final String contactedBy;
  final String product;
  final String price;

  // ------------------ STATIC MAPS ------------------
  static const Map<String, String> stageMap = {
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

  static const Map<String, String> priorityMap = {
    "High": "HIGH",
    "Medium": "MEDIUM",
    "Low": "LOW",
  };

  Lead({
    required this.dealName,
    required this.companyName,
    required this.phone,
    required this.email,
    required this.stage,
    required this.priority,
    required this.contactedBy,
    required this.product,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      "deal_name": dealName,
      "contacted_by": contactedBy,
      "phone": phone,
      "company_name": companyName,
      "product": product,
      "price": price,
      "stage": Lead.stageMap[stage] ?? "NEW",
      "priority": Lead.priorityMap[priority] ?? "MEDIUM",
    };
  }
}

