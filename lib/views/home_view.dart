import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/image_generator_viewmodel.dart';
import '../utils/constants.dart';
import '../widgets/image_card.dart';
import '../widgets/history_list.dart';
import '../widgets/magic_image_container.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ImageGeneratorViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('AI Wallpaper Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Prompt',
                        hintText: 'anime cyberpunk city at night',
                      ),
                      onChanged: (v) => vm.prompt = v,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: vm.style,
                            items: stylePresets
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
                              vm.style = v ?? vm.style;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Style',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: vm.aspect,
                            items:
                                [
                                      'Phone 9:16',
                                      'Square 1:1',
                                      'Landscape 16:9',
                                      'Tablet 4:3',
                                      'Desktop 21:9',
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) {
                              HapticFeedback.lightImpact();
                              vm.aspect = v ?? vm.aspect;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Aspect Ratio',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: vm.state == GeneratorState.loading
                            ? null
                            : () async {
                                await vm.generateImage();
                                if (vm.state == GeneratorState.error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        vm.errorMessage ?? 'Unknown error',
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: vm.state == GeneratorState.loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Generate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Show shimmer loading container or the image
            if (vm.state == GeneratorState.loading) ...[
              MagicImageContainer(
                isLoading: true,
                style: vm.style,
                loadingStep: vm.loadingStep,
                aspectRatio: _getAspectRatio(vm.aspect),
              ),
              const SizedBox(height: 16),
            ] else if (vm.currentImage != null) ...[
              ImageCard(
                model: vm.currentImage!,
                style: vm.style,
                aspect: vm.aspect,
              ),
              const SizedBox(height: 16),
            ],
            const Text('History', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            HistoryList(items: vm.history),
          ],
        ),
      ),
    );
  }

  double _getAspectRatio(String aspect) {
    switch (aspect) {
      case 'Phone 9:16':
        return 9 / 16;
      case 'Square 1:1':
        return 1.0;
      case 'Landscape 16:9':
        return 16 / 9;
      case 'Tablet 4:3':
        return 4 / 3;
      case 'Desktop 21:9':
        return 21 / 9;
      default:
        return 9 / 16;
    }
  }
}
