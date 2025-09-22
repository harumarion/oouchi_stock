import 'dart:async';
import 'dart:math';

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
  AnimationController? _animation;
  Timer? _startTimer;
  double _overflowWidth = 0;
  String _lastText = '';
  double _lastMaxWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant ScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _lastText = '';
    }
  }

  @override
  void dispose() {
    _stopAnimation();
    _scrollController.dispose();
    super.dispose();
  }

  /// スクロールアニメーションを開始する。画面表示名が長い場合のみ呼ばれる
  void _startAnimation() {
    if (_overflowWidth <= 0 || !mounted) {
      return;
    }
    _animation ??= AnimationController(
      vsync: this,
      duration: Duration(
        // 文字列長に合わせてスクロール速度を一定化する（約70px/秒）
        milliseconds: max((_overflowWidth / 70 * 1000).round(), 1500),
      ),
    )
      ..addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_overflowWidth * _animation!.value);
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animation?.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animation?.forward();
        }
      });

    if (_animation!.isAnimating) {
      return;
    }
    _startTimer?.cancel();
    // 画面表示直後に激しく動かないよう1秒待機してから開始
    _startTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _animation?.forward();
      }
    });
  }

  /// アニメーションを停止して位置をリセットする
  void _stopAnimation() {
    _startTimer?.cancel();
    _animation?.stop();
    _animation?.dispose();
    _animation = null;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  /// 表示領域とテキスト長からスクロールの要否を判定する
  void _evaluateOverflow(BoxConstraints constraints) {
    if (_lastText == widget.text && _lastMaxWidth == constraints.maxWidth) {
      return;
    }
    _lastText = widget.text;
    _lastMaxWidth = constraints.maxWidth;

    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final overflow = painter.width - constraints.maxWidth;
    if (overflow <= 0) {
      _overflowWidth = 0;
      _stopAnimation();
    } else {
      _overflowWidth = overflow;
      _startAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _evaluateOverflow(constraints);
        });
        return ClipRect(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            child: Text(widget.text, style: widget.style),
          ),
        );
      },
    );
  }
}
