import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_state.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';

import '../widget/mobile_audience_picker_sheet.dart';
import '../widget/share_mobile_top_bar.dart';

class AnnouncementsMobileScreen extends StatefulWidget {
  const AnnouncementsMobileScreen({super.key});

  @override
  State<AnnouncementsMobileScreen> createState() => _AnnouncementsMobileScreenState();
}

class _AnnouncementsMobileScreenState extends State<AnnouncementsMobileScreen> {
  static const Color _bgScreen = Color(0xFFFEF7F1);
  static const Color _boxFill = Color(0xFFFFD8BE); // Peach Fill
  static const Color _darkInk = Color(0xFF8D5B39); // Deep Terracotta
  static const Color _textMain = Color(0xFF1A1C1E);

  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message content is required')),
      );
      return;
    }

    final targeting = context.read<AudienceBloc>().resolveCreatePostTargeting();
    final isAllUsers = context.read<AudienceBloc>().state.totalSelectedCount == 0;

    context.read<PostBloc>().add(
      CreatePostEvent(
        title: title.isEmpty ? null : title,
        link: null,
        content: content,
        category: 'announcement',
        attachments: const [],
        isAllUsers: isAllUsers,
        userIds: isAllUsers ? const [] : targeting.userIds,
        departmentIds: isAllUsers ? const [] : targeting.departmentIds,
        designationIds: isAllUsers ? const [] : targeting.designationIds,
        publishAfterCreate: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listenWhen: (_, s) => s is PostCreated || s is PostError,
      listener: (context, state) {
        if (state is PostCreated) {
          _titleCtrl.clear();
          _contentCtrl.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement published')),
          );
        }
        if (state is PostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bgScreen,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ShareMobileTopBar(
                title: 'Announcements',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    24 + MediaQuery.paddingOf(context).bottom + 110,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create Announcement',
                        style: GoogleFonts.manrope(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: _textMain,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Broadcast an update to your target audience.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF74777F),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _Label('BROADCAST TITLE'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _titleCtrl,
                        hintText: '',
                        fillColor: _boxFill,
                        textColor: _darkInk,
                      ),
                      const SizedBox(height: 20),
                      const _Label('MESSAGE CONTENT'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _contentCtrl,
                        hintText: '',
                        maxLines: 8,
                        fillColor: _boxFill,
                        textColor: _darkInk,
                      ),
                      const SizedBox(height: 24),
                      const _Label('TARGET AUDIENCE'),
                      const SizedBox(height: 10),
                      const MobileAudiencePickers(),
                      const SizedBox(height: 12),
                      BlocBuilder<AudienceBloc, AudienceState>(
                        builder: (context, state) {
                          final count = state.totalSelectedCount;
                          final text = count == 0 ? 'All users' : '$count selected';
                          return Text(
                            text,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF74777F),
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _SubmitBar(
          label: 'Submit Announcement',
          onPressed: _submit,
          btnColor: _darkInk,
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.label, required this.onPressed, required this.btnColor});

  final String label;
  final VoidCallback onPressed;
  final Color btnColor;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: const Color(0xFF74777F),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hintText,
    required this.fillColor,
    required this.textColor,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final Color fillColor;
  final Color textColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: fillColor.withOpacity(0.7),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: textColor.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: textColor.withOpacity(0.3), width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }
}