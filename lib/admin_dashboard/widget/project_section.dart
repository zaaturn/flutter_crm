import 'package:flutter/material.dart';
import '../model/project.dart';

class ProjectSection extends StatelessWidget {
  final List<Project> projects;

  const ProjectSection({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text("Projects & Tasks",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(width: 6),
            Icon(Icons.view_list_rounded, size: 18),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            itemCount: projects.length,
            itemBuilder: (_, i) {
              final p = projects[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(p.owner),
                ),
                title: Text(p.title),
                subtitle: Text("Due ${p.deadline}"),
                trailing: Chip(
                  label: Text(p.status),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
