import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/lesson_model.dart';
import '../utils/app_theme.dart';
import '../widgets/progress_stepper.dart';
import '../widgets/lesson_card.dart';
import '../widgets/quiz_card.dart';
import '../widgets/completion_card.dart';

enum AcademyView { lessons, quiz, completion }

/// Premium Prompt Academy - Educational experience for learning prompt writing
class PromptLearnerView extends StatefulWidget {
  const PromptLearnerView({super.key});

  @override
  State<PromptLearnerView> createState() => _PromptLearnerViewState();
}

class _PromptLearnerViewState extends State<PromptLearnerView> {
  int _currentLessonIndex = 0;
  int _currentQuizIndex = 0;
  int _quizScore = 0;
  AcademyView _currentView = AcademyView.lessons;

  bool get _isLastLesson =>
      _currentLessonIndex >= LessonData.lessons.length - 1;
  bool get _isLastQuiz =>
      _currentQuizIndex >= LessonData.quizQuestions.length - 1;

  void _nextLesson() {
    if (_isLastLesson) {
      // Move to quiz
      setState(() {
        _currentView = AcademyView.quiz;
        _currentQuizIndex = 0;
      });
    } else {
      setState(() => _currentLessonIndex++);
    }
  }

  void _handleQuizAnswer(bool isCorrect) {
    if (isCorrect) {
      setState(() => _quizScore++);
    }

    if (_isLastQuiz) {
      // Show completion
      setState(() => _currentView = AcademyView.completion);
    } else {
      setState(() => _currentQuizIndex++);
    }
  }

  void _tryPrompt(String prompt) {
    HapticFeedback.mediumImpact();
    // Navigate to generator with pre-filled prompt
    Navigator.pushReplacementNamed(
      context,
      '/generator',
      arguments: {'initialPrompt': prompt},
    );
  }

  void _goToStudio() {
    Navigator.pushReplacementNamed(context, '/generator');
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case AcademyView.lessons:
        return _buildLessonView();
      case AcademyView.quiz:
        return _buildQuizView();
      case AcademyView.completion:
        return _buildCompletionView();
    }
  }

  Widget _buildLessonView() {
    final lesson = LessonData.lessons[_currentLessonIndex];

    return Column(
      key: ValueKey('lesson_$_currentLessonIndex'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: LessonCard(
              lesson: lesson,
              onTryNow: () => _tryPrompt(lesson.examples.first.advanced),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizView() {
    final question = LessonData.quizQuestions[_currentQuizIndex];

    return Column(
      key: ValueKey('quiz_$_currentQuizIndex'),
      children: [
        const SizedBox(height: 20),
        // Quiz header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quiz Time! 🎯',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Text(
                  '${_currentQuizIndex + 1}/${LessonData.quizQuestions.length}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentViolet,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: QuizCard(question: question, onAnswer: _handleQuizAnswer),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionView() {
    return SingleChildScrollView(
      key: const ValueKey('completion'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: CompletionCard(
        lessonsCompleted: LessonData.lessons.length,
        quizScore: _quizScore,
        onContinue: _goToStudio,
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_currentView != AcademyView.lessons) return const SizedBox.shrink();

    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (_isLastLesson) {
              // Show interstitial before starting quiz
              appOpenAdManager.loadInterstitialAndShow(onComplete: _nextLesson);
            } else {
              _nextLesson();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentViolet.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLastLesson ? 'Start Quiz' : 'Next Lesson',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Prompt Academy',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.backgroundDark,
                    AppTheme.accentViolet.withOpacity(0.05),
                    AppTheme.accentCyan.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Mesh gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: AppTheme.meshGradient),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Progress stepper (only show during lessons and quiz)
                if (_currentView != AcademyView.completion)
                  ProgressStepper(
                    totalSteps: LessonData.lessons.length,
                    currentStep: _currentView == AcademyView.lessons
                        ? _currentLessonIndex
                        : LessonData.lessons.length,
                  ),

                // Main content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildCurrentView(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation button (for lessons only)
          _buildBottomBar(),
        ],
      ),
    );
  }
}
