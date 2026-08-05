import 'package:flutter/material.dart';
import '../utils/size_config.dart';

/// Modern Modal Bottom Sheet Calculator Widget
class CalculatorModalSheet extends StatefulWidget {
  final Color accentColor;
  final ValueChanged<double> onResultConfirmed;

  const CalculatorModalSheet({
    super.key,
    required this.accentColor,
    required this.onResultConfirmed,
  });

  /// Helper to present this calculator cleanly as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required Color accentColor,
    required ValueChanged<double> onResultConfirmed,
  }) {
    FocusScope.of(context).unfocus();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CalculatorModalSheet(
        accentColor: accentColor,
        onResultConfirmed: onResultConfirmed,
      ),
    );
  }

  @override
  State<CalculatorModalSheet> createState() => _CalculatorModalSheetState();
}

class _CalculatorModalSheetState extends State<CalculatorModalSheet> {
  // Tokens list alternating between numbers (as strings) and operators (+, -, ×, ÷)
  final List<String> _tokens = [];
  String _currentInput = '';

  /// Computes real-time live total using left-to-right sequential evaluation
  double get _liveTotal {
    List<String> evalTokens = List.from(_tokens);
    if (_currentInput.isNotEmpty) {
      evalTokens.add(_currentInput);
    }
    if (evalTokens.isEmpty) return 0.0;

    double result = double.tryParse(evalTokens[0]) ?? 0.0;

    for (int i = 1; i < evalTokens.length - 1; i += 2) {
      String op = evalTokens[i];
      double nextVal = double.tryParse(evalTokens[i + 1]) ?? 0.0;
      switch (op) {
        case '+':
          result += nextVal;
          break;
        case '-':
          result -= nextVal;
          break;
        case '×':
          result *= nextVal;
          break;
        case '÷':
          result = nextVal != 0 ? result / nextVal : result;
          break;
      }
    }
    return result;
  }

  String get _expressionString {
    String expr = _tokens.join(' ');
    if (_currentInput.isNotEmpty) {
      expr = expr.isEmpty ? _currentInput : '$expr $_currentInput';
    }
    return expr;
  }

  void _onDigitPressed(String digit) {
    setState(() {
      if (digit == '.') {
        if (!_currentInput.contains('.')) {
          _currentInput = _currentInput.isEmpty ? '0.' : '$_currentInput.';
        }
      } else {
        if (_currentInput == '0') {
          _currentInput = digit;
        } else {
          _currentInput += digit;
        }
      }
    });
  }

  void _onOperatorPressed(String op) {
    setState(() {
      if (_currentInput.isNotEmpty) {
        _tokens.add(_currentInput);
        _tokens.add(op);
        _currentInput = '';
      } else if (_tokens.isNotEmpty) {
        // Replace last operator if user presses another operator consecutively
        if (['+', '-', '×', '÷'].contains(_tokens.last)) {
          _tokens[_tokens.length - 1] = op;
        }
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      _tokens.clear();
      _currentInput = '';
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_currentInput.isNotEmpty) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      } else if (_tokens.isNotEmpty) {
        _tokens.removeLast(); // Remove operator
        if (_tokens.isNotEmpty) {
          _currentInput = _tokens.removeLast(); // Pop back previous number
        }
      }
    });
  }

  String _formatNumber(double val) {
    if (val.isNaN || val.isInfinite) return '0';
    if (val == val.toInt().toDouble()) {
      return val.toInt().toString();
    }
    String s = val.toStringAsFixed(4);
    while (s.contains('.') && (s.endsWith('0') || s.endsWith('.'))) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  void _confirmAmount() {
    double total = _liveTotal;
    if (total > 0) {
      widget.onResultConfirmed(total);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final total = _liveTotal;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 6.w,
        right: 6.w,
        top: 2.h,
        bottom: MediaQuery.of(context).padding.bottom + 2.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 12.w,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 2.h),

          // Live Total & Expression Display Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : widget.accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Expression string
                Text(
                  _expressionString.isEmpty ? '0' : _expressionString,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.8.h),
                // Prominent Live Evaluated Total
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    '₦ ${_formatNumber(total)}',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: widget.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.5.h),

          // Keypad Rows with Circular Buttons
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton('AC', color: Colors.redAccent, onPressed: _onClearPressed),
                  _buildCircleButton('⌫', color: Colors.orangeAccent, onPressed: _onBackspacePressed),
                  _buildCircleButton('÷', isOperator: true, onPressed: () => _onOperatorPressed('÷')),
                  _buildCircleButton('×', isOperator: true, onPressed: () => _onOperatorPressed('×')),
                ],
              ),
              SizedBox(height: 1.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton('7', onPressed: () => _onDigitPressed('7')),
                  _buildCircleButton('8', onPressed: () => _onDigitPressed('8')),
                  _buildCircleButton('9', onPressed: () => _onDigitPressed('9')),
                  _buildCircleButton('-', isOperator: true, onPressed: () => _onOperatorPressed('-')),
                ],
              ),
              SizedBox(height: 1.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton('4', onPressed: () => _onDigitPressed('4')),
                  _buildCircleButton('5', onPressed: () => _onDigitPressed('5')),
                  _buildCircleButton('6', onPressed: () => _onDigitPressed('6')),
                  _buildCircleButton('+', isOperator: true, onPressed: () => _onOperatorPressed('+')),
                ],
              ),
              SizedBox(height: 1.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton('1', onPressed: () => _onDigitPressed('1')),
                  _buildCircleButton('2', onPressed: () => _onDigitPressed('2')),
                  _buildCircleButton('3', onPressed: () => _onDigitPressed('3')),
                  _buildCircleButton('.', onPressed: () => _onDigitPressed('.')),
                ],
              ),
              SizedBox(height: 2.5.h),

              // Bottom Confirmation Pill Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: total > 0 ? _confirmAmount : null,
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  label: Text(
                    'Use Amount (₦ ${_formatNumber(total)})',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? Colors.white12 : Colors.grey.shade300,
                    disabledForegroundColor: isDark ? Colors.white38 : Colors.grey.shade500,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    String label, {
    Color? color,
    bool isOperator = false,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double buttonSize = 16.w;

    Color btnBg = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100;
    Color txtColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    if (isOperator) {
      btnBg = widget.accentColor.withValues(alpha: isDark ? 0.25 : 0.12);
      txtColor = widget.accentColor;
    }
    if (color != null) {
      txtColor = color;
      btnBg = color.withValues(alpha: isDark ? 0.15 : 0.1);
    }

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: btnBg,
        border: Border.all(
          color: isOperator
              ? widget.accentColor.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
