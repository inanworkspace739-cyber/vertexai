/// Data models for Prompt Academy lessons and quizzes
class Lesson {
  final String title;
  final String description;
  final List<PromptExample> examples;
  final String tip;

  const Lesson({
    required this.title,
    required this.description,
    required this.examples,
    required this.tip,
  });
}

class PromptExample {
  final String basic;
  final String advanced;
  final String explanation;

  const PromptExample({
    required this.basic,
    required this.advanced,
    required this.explanation,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// Lesson content data
class LessonData {
  static const List<Lesson> lessons = [
    Lesson(
      title: 'The Basics',
      description:
          'Learn the fundamental elements of a great prompt: subject, style, and mood.',
      examples: [
        PromptExample(
          basic: 'cat',
          advanced: 'majestic cat, oil painting, warm lighting',
          explanation:
              'Adding style and lighting transforms a simple subject into art',
        ),
        PromptExample(
          basic: 'house',
          advanced: 'cozy cottage, watercolor style, sunset atmosphere',
          explanation: 'Descriptive words create a specific vision',
        ),
      ],
      tip: '💡 Always include: Subject + Style + Mood',
    ),
    Lesson(
      title: 'Adding Details',
      description:
          'Use descriptive adjectives and composition keywords to enhance your prompts.',
      examples: [
        PromptExample(
          basic: 'sunset',
          advanced:
              'breathtaking sunset over mountains, golden hour, cinematic wide shot',
          explanation: 'Composition terms like "wide shot" guide the framing',
        ),
        PromptExample(
          basic: 'city',
          advanced:
              'futuristic metropolis, towering skyscrapers, aerial view, neon lights',
          explanation: 'Multiple descriptive details build a rich scene',
        ),
      ],
      tip: '💡 Use composition keywords: wide shot, close-up, aerial view',
    ),
    Lesson(
      title: 'Style Keywords',
      description:
          'Master art styles and rendering techniques to achieve specific aesthetics.',
      examples: [
        PromptExample(
          basic: 'robot',
          advanced:
              'futuristic robot, cyberpunk style, neon accents, 8k render',
          explanation: 'Style keywords define the artistic approach',
        ),
        PromptExample(
          basic: 'portrait',
          advanced:
              'elegant portrait, renaissance painting, dramatic chiaroscuro lighting',
          explanation: 'Historical art styles create timeless aesthetics',
        ),
      ],
      tip:
          '💡 Popular styles: cyberpunk, anime, realistic, watercolor, oil painting',
    ),
    Lesson(
      title: 'Lighting & Mood',
      description:
          'Control atmosphere and emotion through lighting and environmental keywords.',
      examples: [
        PromptExample(
          basic: 'forest',
          advanced:
              'mystical forest, volumetric fog, soft moonlight, ethereal atmosphere',
          explanation: 'Lighting keywords create mood and depth',
        ),
        PromptExample(
          basic: 'street',
          advanced:
              'rainy street at night, neon reflections, cinematic noir lighting',
          explanation: 'Weather and time of day enhance atmosphere',
        ),
      ],
      tip:
          '💡 Lighting: golden hour, volumetric fog, rim lighting, soft shadows',
    ),
  ];

  static const List<QuizQuestion> quizQuestions = [
    QuizQuestion(
      question: 'Which keyword adds cinematic lighting?',
      options: ['blue color', 'golden hour', 'big size', 'fast speed'],
      correctIndex: 1,
      explanation:
          '"Golden hour" refers to the warm, soft light during sunrise/sunset.',
    ),
    QuizQuestion(
      question: 'What makes a prompt more specific?',
      options: [
        'Making it longer',
        'Using random words',
        'Adding descriptive adjectives',
        'Repeating the subject',
      ],
      correctIndex: 2,
      explanation:
          'Descriptive adjectives provide clear, specific details about your vision.',
    ),
    QuizQuestion(
      question: 'Which style keyword creates a painted look?',
      options: ['photograph', 'oil painting', '3D render', 'blueprint'],
      correctIndex: 1,
      explanation:
          '"Oil painting" tells the AI to create artwork in a traditional painted style.',
    ),
  ];
}
