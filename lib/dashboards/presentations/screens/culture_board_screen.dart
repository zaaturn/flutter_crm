import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';

class CultureBoardsScreen extends StatefulWidget {
  const CultureBoardsScreen({super.key});

  @override
  State<CultureBoardsScreen> createState() => _CultureBoardsScreenState();
}

class _CultureBoardsScreenState extends State<CultureBoardsScreen> {
  bool _allUsers = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Culture Boards',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Shape the collective experience of our workspace. Participate in active boards to inspire, celebrate, and welcome your teammates.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                'Active Boards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Text(
                  '3 ONGOING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF065F46),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: _allUsers,
                activeColor: const Color(0xFF2F7D6D),
                onChanged: (v) => setState(() => _allUsers = v ?? true),
              ),
              const Text(
                'All Users',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _allUsers
                      ? 'Everyone will see these posts.'
                      : 'Pick specific users/departments/designations on the right.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _BoardsLeft(allUsers: _allUsers)),
              const SizedBox(width: 18),
              Expanded(flex: 5, child: _BoardsRightStack(allUsers: _allUsers)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoardsLeft extends StatefulWidget {
  final bool allUsers;
  const _BoardsLeft({required this.allUsers});
  @override
  State<_BoardsLeft> createState() => _BoardsLeftState();
}

class _BoardsLeftState extends State<_BoardsLeft> {
  final _quoteCtrl = TextEditingController();
  bool _pendingSubmit = false;

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            error ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _quoteCtrl.dispose();
    super.dispose();
  }

  void _submitQuote() {
    final content = _quoteCtrl.text.trim();
    if (content.isEmpty) return;
    final audienceBloc = context.read<AudienceBloc>();
    final targeting = audienceBloc.resolveCreatePostTargeting();
    setState(() => _pendingSubmit = true);
    context.read<PostBloc>().add(
          CreatePostEvent(
            title: null,
            content: content,
            category: 'quote',
            attachments: const [],
            isAllUsers: widget.allUsers,
            userIds: widget.allUsers ? const [] : targeting.userIds,
            departmentIds: widget.allUsers ? const [] : targeting.departmentIds,
            designationIds:
                widget.allUsers ? const [] : targeting.designationIds,
            publishAfterCreate: false,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (!_pendingSubmit) return;
        if (state is PostCreated) {
          _quoteCtrl.clear();
          _snack('Quote submitted successfully');
          setState(() => _pendingSubmit = false);
        } else if (state is PostError) {
          _snack(state.message, error: true);
          setState(() => _pendingSubmit = false);
        }
      },
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.format_quote_rounded,
                    color: Color(0xFF3D8C7A)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quotes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Daily inspiration from the team',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Text(
                  '+14',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _quoteCtrl,
            hintText: 'Write something to inspire someone...',
            maxLines: 8,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                final busy = state is PostLoading;
                return ElevatedButton(
                  onPressed: busy ? null : _submitQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F7D6D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      : const Text('Submit',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                );
              },
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _BoardsRightStack extends StatelessWidget {
  final bool allUsers;
  const _BoardsRightStack({required this.allUsers});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CultureMiniCard(
          icon: Icons.cake_outlined,
          iconBg: Color(0xFFFFF0F3),
          iconColor: Color(0xFFE91E63),
          title: 'Birthday Wishes',
          subtitle: 'Celebrating Sarah & Michael',
          hint: 'Write your wish...',
          buttonText: 'Send Wish',
          buttonColor: Color(0xFFF472B6),
          category: 'birthday',
          allUsers: allUsers,
        ),
        const SizedBox(height: 14),
        _CultureMiniCard(
          icon: Icons.person_add_alt_1_outlined,
          iconBg: Color(0xFFEDF9F0),
          iconColor: Color(0xFF2E7D32),
          title: 'New Hire Welcome',
          subtitle: 'Welcome Amit to the team',
          hint: 'Write a welcome note...',
          buttonText: 'Post Welcome',
          buttonColor: Color(0xFF86EFAC),
          category: 'new_hire',
          allUsers: allUsers,
        ),
      ],
    );
  }
}

class _CultureMiniCard extends StatefulWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String hint;
  final String buttonText;
  final Color buttonColor;
  final String category;
  final bool allUsers;

  const _CultureMiniCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.buttonText,
    required this.buttonColor,
    required this.category,
    required this.allUsers,
  });

  @override
  State<_CultureMiniCard> createState() => _CultureMiniCardState();
}

class _CultureMiniCardState extends State<_CultureMiniCard> {
  final _ctrl = TextEditingController();
  bool _pendingSubmit = false;

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            error ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
    setState(() => _pendingSubmit = true);
    context.read<PostBloc>().add(
          CreatePostEvent(
            title: null,
            content: content,
            category: widget.category,
            attachments: const [],
            isAllUsers: widget.allUsers,
            userIds: widget.allUsers ? const [] : targeting.userIds,
            departmentIds: widget.allUsers ? const [] : targeting.departmentIds,
            designationIds:
                widget.allUsers ? const [] : targeting.designationIds,
            publishAfterCreate: false,
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
          final label = widget.category == 'birthday'
              ? 'Birthday wish'
              : widget.category == 'new_hire'
                  ? 'Welcome post'
                  : 'Post';
          _snack('$label submitted successfully');
          setState(() => _pendingSubmit = false);
        } else if (state is PostError) {
          _snack(state.message, error: true);
          setState(() => _pendingSubmit = false);
        }
      },
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Field(controller: _ctrl, hintText: widget.hint, maxLines: 5),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.buttonColor,
                foregroundColor: const Color(0xFF111827),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.buttonText,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF6FA99A), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  const _Field({
    required this.controller,
    required this.hintText,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.45),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6FA99A), width: 2),
        ),
      ),
    );
  }
}

