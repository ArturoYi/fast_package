import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/material.dart';

/// In-app controls for the public web gallery.
///
/// device_preview 3.x moved the picker into DevTools. GitHub Pages visitors
/// do not have that panel, so this menu drives [DevicePreview.maybeController].
class WebDevicePreviewControls extends StatelessWidget {
  const WebDevicePreviewControls({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    final DevicePreviewController? controller = DevicePreview.maybeController;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? _) {
        return Align(
          alignment: Alignment.bottomRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FloatingActionButton.small(
                tooltip: 'Device preview',
                onPressed: () => _openSheet(controller),
                child: const Icon(Icons.phone_iphone),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSheet(DevicePreviewController controller) {
    final BuildContext? navContext = navigatorKey.currentContext;
    if (navContext == null) {
      return Future<void>.value();
    }
    return showModalBottomSheet<void>(
      context: navContext,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ListenableBuilder(
          listenable: controller,
          builder: (BuildContext context, Widget? _) {
            return _PreviewSheet(controller: controller);
          },
        );
      },
    );
  }
}

class _PreviewSheet extends StatelessWidget {
  const _PreviewSheet({required this.controller});

  final DevicePreviewController controller;

  static const List<DevicePreset> _presets = <DevicePreset>[
    DevicePresets.iPhoneSe3,
    DevicePresets.iPhone16,
    DevicePresets.iPhone16ProMax,
    DevicePresets.pixel10,
    DevicePresets.galaxyS25,
    DevicePresets.iPadMini,
  ];

  @override
  Widget build(BuildContext context) {
    final DeviceSimulation? simulation = controller.simulation;
    final String? presetId = simulation?.presetId;
    final bool isLandscape = simulation?.orientation == Orientation.landscape;
    final bool isDark = simulation?.platformBrightness == Brightness.dark;
    final bool keyboardVisible = simulation?.keyboardInset != null;
    final DevicePreset? currentPreset = presetId == null
        ? null
        : DevicePresets.byId(presetId);
    final bool canRaiseKeyboard =
        currentPreset?.keyboardHeight(
          simulation?.orientation ?? Orientation.portrait,
        ) !=
        null;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Device preview',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final DevicePreset preset in _presets)
                    ChoiceChip(
                      label: Text(preset.name),
                      selected: preset.id == presetId,
                      onSelected: (_) => controller.applyPreset(preset),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                title: const Text('Landscape'),
                value: isLandscape,
                onChanged: simulation == null
                    ? null
                    : (bool value) {
                        controller.setOrientation(
                          value ? Orientation.landscape : Orientation.portrait,
                        );
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                title: const Text('Dark mode'),
                value: isDark,
                onChanged: (bool value) {
                  controller.update(
                    (DeviceSimulation current) => current.copyWith(
                      platformBrightness: value ? Brightness.dark : null,
                    ),
                  );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                title: const Text('Keyboard'),
                value: keyboardVisible,
                onChanged: !canRaiseKeyboard
                    ? null
                    : (bool value) {
                        final DevicePreset? preset = currentPreset;
                        controller.update((DeviceSimulation current) {
                          return current.copyWith(
                            keyboardInset: value
                                ? preset?.keyboardHeight(current.orientation)
                                : null,
                          );
                        });
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
