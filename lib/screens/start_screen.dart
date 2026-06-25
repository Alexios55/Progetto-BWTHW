
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lane1Controller;
  late final AnimationController _lane2Controller;
  late final AnimationController _lane3Controller;

  final List<_AnimatedTagData> lane1Tags = const [
    _AnimatedTagData(
      text: 'Track meals mindfully',
      width: 220,
      isFilled: false,
    ),
    _AnimatedTagData(
      text: 'Monitor your weight',
      width: 205,
      isFilled: false,
    ),
    _AnimatedTagData(
      text: 'Build healthy habits',
      width: 215,
      isFilled: false,
    ),
  ];

  final List<_AnimatedTagData> lane2Tags = const [
    _AnimatedTagData(
      text: 'Track your analyses',
      width: 205,
      isFilled: false,
    ),
    _AnimatedTagData(
      text: 'Get a smart diet plan',
      width: 220,
      isFilled: false,
    ),
    _AnimatedTagData(
      text: 'Feel better daily',
      width: 180,
      isFilled: false,
    ),
  ];

  final List<_AnimatedTagData> lane3Tags = const [
    _AnimatedTagData(
      text: 'Save body measurements',
      width: 235,
      isFilled: false,
    ),
    _AnimatedTagData(
      text: 'Follow calorie balance',
      width: 225,
      isFilled: false,
    ),
    _AnimatedTagData(
      text: 'Improve your nutrition',
      width: 225,
      isFilled: false,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _lane1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _lane2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _lane3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _lane1Controller.dispose();
    _lane2Controller.dispose();
    _lane3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF405F91);
    const Color lightBackground = Color(0xFFF4F7FC);

    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 36),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    color: primaryBlue,
                    height: 1.0,
                  ),
                  children: [
                    TextSpan(
                      text: "Let’s make\n",
                      style: GoogleFonts.montserrat(
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                        height: 0.95,
                      ),
                    ),
                    TextSpan(
                      text: "your days\n",
                      style: GoogleFonts.montserrat(
                        fontSize: 46,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: primaryBlue,
                        height: 0.95,
                      ),
                    ),
                    TextSpan(
                      text: "healthier",
                      style: GoogleFonts.montserrat(
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                        height: 0.95,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),

              _AnimatedTagLane(
                controller: _lane1Controller,
                tags: lane1Tags,
                reverseDirection: false,
              ),
              const SizedBox(height: 16),
              _AnimatedTagLane(
                controller: _lane2Controller,
                tags: lane2Tags,
                reverseDirection: true,
              ),
              const SizedBox(height: 16),
              _AnimatedTagLane(
                controller: _lane3Controller,
                tags: lane3Tags,
                reverseDirection: false,
              ),

              const Spacer(),

              SizedBox(
                width: 230,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    'Get Started Now',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedTagLane extends StatelessWidget {
  final AnimationController controller;
  final List<_AnimatedTagData> tags;
  final bool reverseDirection;

  const _AnimatedTagLane({
    required this.controller,
    required this.tags,
    required this.reverseDirection,
  });

  double get _spacing => 14;

  double get _contentWidth {
    double total = 0;
    for (final tag in tags) {
      total += tag.width;
    }
    total += _spacing * (tags.length - 1);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final double fullWidth = _contentWidth + 28;

    return SizedBox(
      height: 54,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final double offset = reverseDirection
                ? (controller.value * fullWidth) - fullWidth
                : -controller.value * fullWidth;

            return Stack(
              children: [
                Positioned(
                  left: offset,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      _TagRow(tags: tags, spacing: _spacing),
                      const SizedBox(width: 28),
                      _TagRow(tags: tags, spacing: _spacing),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  final List<_AnimatedTagData> tags;
  final double spacing;

  const _TagRow({
    required this.tags,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < tags.length; i++) ...[
          _AnimatedTag(data: tags[i]),
          if (i != tags.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}

class _AnimatedTag extends StatelessWidget {
  final _AnimatedTagData data;

  const _AnimatedTag({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF405F91);

    return CustomPaint(
      painter: _DashedRoundedRectPainter(
        color: primaryBlue.withOpacity(0.45),
        strokeWidth: 1.5,
        dashWidth: 5,
        dashGap: 4,
        radius: 25,
      ),
      child: Container(
        width: data.width,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            data.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedTagData {
  final String text;
  final double width;
  final bool isFilled;

  const _AnimatedTagData({
    required this.text,
    required this.width,
    required this.isFilled,
  });
}

class _DashedRoundedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double radius;

  const _DashedRoundedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double nextDistance = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, nextDistance),
          paint,
        );
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.radius != radius;
  }
}