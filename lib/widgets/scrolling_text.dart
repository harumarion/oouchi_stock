import 'dart:async';
import 'package:flutter/material.dart';

/// 長いテキストを横スクロールさせるウィジェット
/// 在庫一覧などで品種名と商品名が長すぎる場合に利用する
class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  const ScrollingText(this.text, {super.key, this.style});

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animation;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animation =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addListener(() {
            if (!_scrollController.hasClients) return;
            final max = _scrollController.position.maxScrollExtent;
            _scrollController.jumpTo(max * _animation.value);
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animation.reverse();
            }
          });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer =
          Timer(const Duration(seconds: 3), () => _animation.forward());
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _animation.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(widget.text, style: widget.style),
      ),
    );
  }
}
