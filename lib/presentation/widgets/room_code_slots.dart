import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/room_code_generator.dart';

/// Figma-style underscore room-code entry (6 slots).
class RoomCodeSlots extends StatefulWidget {
  const RoomCodeSlots({
    super.key,
    required this.onCompleted,
    this.onChanged,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<RoomCodeSlots> createState() => RoomCodeSlotsState();
}

class RoomCodeSlotsState extends State<RoomCodeSlots> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _completedFired = false;

  String get code => RoomCodeGenerator.normalize(_controller.text);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _openKeyboard());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void clear() {
    _completedFired = false;
    _controller.clear();
    setState(() {});
    _openKeyboard();
  }

  void _openKeyboard() {
    if (!mounted) return;
    FocusScope.of(context).requestFocus(_focusNode);
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  @override
  Widget build(BuildContext context) {
    final chars = code.padRight(AppConstants.roomCodeLength).characters.toList();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openKeyboard,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(AppConstants.roomCodeLength, (index) {
              final ch = chars[index].trim();
              final filled = ch.isNotEmpty;
              final isActive = code.length == index && _focusNode.hasFocus;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 120),
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: filled
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                              letterSpacing: 0,
                            ),
                        child: Text(filled ? ch : ' '),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        height: 2,
                        color: isActive
                            ? AppColors.accent
                            : AppColors.textPrimary.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          // Full-size transparent field so Android IME can attach correctly.
          // A 1x1 field often fails to show the keyboard or anchors it oddly.
          Positioned.fill(
            child: Opacity(
              opacity: 0.01,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                showCursor: false,
                enableInteractiveSelection: false,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 1,
                  height: 1,
                ),
                cursorColor: Colors.transparent,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(AppConstants.roomCodeLength),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final normalized =
                        RoomCodeGenerator.normalize(newValue.text);
                    return TextEditingValue(
                      text: normalized,
                      selection:
                          TextSelection.collapsed(offset: normalized.length),
                    );
                  }),
                ],
                onTap: _openKeyboard,
                onChanged: (value) {
                  setState(() {});
                  final normalized = RoomCodeGenerator.normalize(value);
                  widget.onChanged?.call(normalized);
                  if (normalized.length == AppConstants.roomCodeLength) {
                    if (!_completedFired) {
                      _completedFired = true;
                      widget.onCompleted(normalized);
                    }
                  } else {
                    _completedFired = false;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
