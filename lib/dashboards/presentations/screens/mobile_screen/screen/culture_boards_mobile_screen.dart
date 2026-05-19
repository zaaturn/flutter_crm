import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';

import '../widget/mobile_audience_picker_sheet.dart';
import '../widget/share_mobile_top_bar.dart';

class CultureBoardsMobileScreen extends StatelessWidget {
  const CultureBoardsMobileScreen({super.key});

  static const Color _bgScreen = Color(0xFFFEF7F1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ShareMobileTopBar(
              title: 'Culture',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  24 + MediaQuery.paddingOf(context).bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Community Hub',
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1E),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connect, celebrate, and welcome our newest team members.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF74777F),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // TARGET AUDIENCE SECTION
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MiniTitle('TARGET AUDIENCE'),
                          SizedBox(height: 12),
                          MobileAudiencePickers(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    _CultureCard(
                      icon: Icons.format_quote_rounded,
                      title: 'Daily Quotes',
                      hint: 'Share an inspiring thought...',
                      buttonText: 'Post Quote',
                      category: 'quote',
                      baseColor: const Color(0xFFFFD8BE), // Peach
                      darkColor: const Color(0xFF8D5B39),  // Darker Ink
                    ),
                    const SizedBox(height: 16),
                    _CultureCard(
                      icon: Icons.cake_outlined,
                      title: 'Birthday Wishes',
                      hint: 'Write a happy birthday note...',
                      buttonText: 'Send Wish',
                      category: 'birthday',
                      baseColor: const Color(0xFFD1D5FF), // Purple
                      darkColor: const Color(0xFF4C4DBC),  // Darker Ink
                    ),
                    const SizedBox(height: 16),
                    _CultureCard(
                      icon: Icons.waving_hand_outlined,
                      title: 'New Hire Welcome',
                      hint: 'Share a welcome message...',
                      buttonText: 'Post Welcome',
                      category: 'new_hire',
                      baseColor: const Color(0xFFC0EBEA), // Teal
                      darkColor: const Color(0xFF1B8D8B),  // Darker Ink
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CultureCard extends StatefulWidget {
  const _CultureCard({
    required this.icon,
    required this.title,
    required this.hint,
    required this.buttonText,
    required this.category,
    required this.baseColor,
    required this.darkColor,
  });

  final IconData icon;
  final String title;
  final String hint;
  final String buttonText;
  final String category;
  final Color baseColor;
  final Color darkColor;

  @override
  State<_CultureCard> createState() => _CultureCardState();
}

class _CultureCardState extends State<_CultureCard> {
  final _ctrl = TextEditingController();
  bool _pendingSubmit = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _ctrl.text.trim();
    if (content.isEmpty) return;

    final audienceBloc = context.read<AudienceBloc>();
    final targeting = audienceBloc.resolveCreatePostTargeting();
    final isAllUsers = audienceBloc.state.totalSelectedCount == 0;

    setState(() => _pendingSubmit = true);
    context.read<PostBloc>().add(
      CreatePostEvent(
        title: null,
        link: null,
        content: content,
        category: widget.category,
        attachments: const [],
        isAllUsers: isAllUsers,
        userIds: isAllUsers ? const [] : targeting.userIds,
        departmentIds: isAllUsers ? const [] : targeting.departmentIds,
        designationIds: isAllUsers ? const [] : targeting.designationIds,
        publishAfterCreate: false,
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (!_pendingSubmit) return;
        if (state is PostCreated) {
          _ctrl.clear();
          _snack('${widget.title} submitted');
          setState(() => _pendingSubmit = false);
        } else if (state is PostError) {
          _snack(state.message, error: true);
          setState(() => _pendingSubmit = false);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.baseColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: widget.darkColor.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.icon, color: widget.darkColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: widget.darkColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.darkColor,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.inter(color: widget.darkColor.withOpacity(0.4)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                final busy = state is PostLoading;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: busy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.darkColor, // Matching button
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: busy
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      widget.buttonText,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTitle extends StatelessWidget {
  const _MiniTitle(this.text);

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