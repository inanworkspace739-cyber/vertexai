import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson_model.dart';
import '../utils/app_theme.dart';

enum AnswerState { idle, correct, wrong }

/// Quiz card with multiple choice questions and instant feedback
class QuizCard extends StatefulWidget {
  final QuizQuestion question;
  final Function(bool isCorrect) onAnswer;

  const QuizCard({super.key, required this.question, required this.onAnswer});

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  AnswerState _answerState = AnswerState.idle;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleAnswer(int index) {
    if (_answerState != AnswerState.idle) return;

    setState(() => _selectedIndex = index);

    final isCorrect = index == widget.question.correctIndex;

    if (isCorrect) {
      HapticFeedback.lightImpact();
      setState(() => _answerState = AnswerState.correct);
      // Auto-advance after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        widget.onAnswer(true);
      });
    } else {
      HapticFeedback.mediumImpact();
      setState(() => _answerState = AnswerState.wrong);
      _shakeController.forward(from: 0);
      // Reset after shake
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _selectedIndex = null;
            _answerState = AnswerState.idle;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentViolet.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.quiz_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.question.question,
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Answer options
                ...List.generate(widget.question.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AnswerButton(
                      text: widget.question.options[index],
                      isSelected: _selectedIndex == index,
                      answerState: _selectedIndex == index
                          ? _answerState
                          : AnswerState.idle,
                      shakeAnimation: _shakeAnimation,
                      onTap: () => _handleAnswer(index),
                    ),
                  );
                }),

                // Explanation (shown after correct answer)
                if (_answerState == AnswerState.correct) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade400.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.question.explanation,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final AnswerState answerState;
  final Animation<double> shakeAnimation;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.text,
    required this.isSelected,
    required this.answerState,
    required this.shakeAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (!isSelected) return Colors.transparent;
      switch (answerState) {
        case AnswerState.correct:
          return Colors.green.shade400;
        case AnswerState.wrong:
          return Colors.red.shade400;
        case AnswerState.idle:
          return Colors.transparent;
      }
    }

    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: answerState == AnswerState.wrong && isSelected
              ? Offset(
                  shakeAnimation.value *
                      (shakeAnimation.value.isNegative ? -1 : 1),
                  0,
                )
              : Offset.zero,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? getColor() : AppTheme.glassBorder,
              width: 2,
            ),
            boxShadow: isSelected && answerState == AnswerState.correct
                ? [
                    BoxShadow(
                      color: Colors.green.shade400.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? getColor() : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? getColor() : AppTheme.textMuted,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        answerState == AnswerState.correct
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
