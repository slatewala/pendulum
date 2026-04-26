import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const PendulumApp());

class PendulumApp extends StatelessWidget {
  const PendulumApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pendulum',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const GamePage(),
      );
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final _sfx = AudioPlayer();
  final _rng = Random();
  Offset _anchor = const Offset(150, 100);
  Offset _ball = const Offset(150, 300);
  Offset _vel = Offset.zero;
  bool _attached = true;
  double _platformX = 250;
  double _platformY = 500;
  double _platformW = 100;
  int _score = 0;
  int _best = 0;
  bool _dead = false;
  Duration _last = Duration.zero;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_size == Size.zero) {
      _size = MediaQuery.of(context).size;
      _reset(true);
    }
  }

  void _reset(bool full) {
    final s = _size == Size.zero ? MediaQuery.of(context).size : _size;
    _size = s;
    if (full) {
      _score = 0;
      _dead = false;
    }
    _platformY = 240 + _rng.nextDouble() * (s.height - 380);
    _platformX = 60 + _rng.nextDouble() * (s.width - 200);
    _platformW = max(70, 140 - _score.toDouble());
    _anchor = Offset(s.width/2, 80);
    final ropeLen = 180 + _rng.nextDouble() * 120;
    final startAngle = -pi/2 + (_rng.nextBool() ? -0.9 : 0.9);
    _ball = _anchor + Offset(cos(startAngle), sin(startAngle)) * ropeLen;
    _vel = Offset.zero;
    _attached = true;
    setState(() {});
  }

  void _tick(Duration t) {
    final dt = (t - _last).inMicroseconds / 1e6;
    _last = t;
    if (dt > 0.1 || _size == Size.zero || _dead) return;
    setState(() {
      const g = 1400.0;
      if (_attached) {
        // pendulum: project gravity perpendicular to rope
        final r = _ball - _anchor;
        final ropeLen = r.distance;
        final tan = Offset(-r.dy, r.dx) / ropeLen;
        final at = (Offset(0, g).dx * tan.dx + Offset(0, g).dy * tan.dy);
        _vel = _vel + tan * (at * dt);
        _vel = _vel * 0.999;
        _ball = _ball + _vel * dt;
        // re-project to rope length
        final r2 = _ball - _anchor;
        _ball = _anchor + r2 / r2.distance * ropeLen;
      } else {
        _vel = Offset(_vel.dx, _vel.dy + g * dt);
        _ball = _ball + _vel * dt;
        // landing check
        if (_ball.dy > _platformY &&
            _ball.dx > _platformX &&
            _ball.dx < _platformX + _platformW) {
          _score++;
          if (_score > _best) _best = _score;
          _sfx.play(AssetSource('sfx.wav'));
          _reset(false);
          return;
        }
        if (_ball.dy > _size.height + 40 || _ball.dx < -40 || _ball.dx > _size.width + 40) {
          _dead = true;
        }
      }
    });
  }

  void _release() {
    if (_dead) { _reset(true); return; }
    if (_attached) setState(() => _attached = false);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sfx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF23022E),
      body: GestureDetector(
        onTap: _release,
        child: Stack(children: [
          CustomPaint(
            size: Size.infinite,
            painter: _Painter(
              anchor: _anchor, ball: _ball, attached: _attached,
              platformX: _platformX, platformY: _platformY, platformW: _platformW,
            ),
          ),
          Positioned(
            top: 50, left: 0, right: 0,
            child: Column(children: [
              Text('$_score',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              Text('best $_best', style: const TextStyle(color: Colors.white60)),
            ]),
          ),
          if (_dead)
            const Center(
              child: Text('FALLEN · TAP TO RETRY',
                  style: TextStyle(fontSize: 24, color: Color(0xFFFF6B6B))),
            ),
          const Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: Text('tap to release rope · land on platform',
                  style: TextStyle(color: Colors.white38)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final Offset anchor, ball;
  final bool attached;
  final double platformX, platformY, platformW;
  _Painter({required this.anchor, required this.ball, required this.attached,
            required this.platformX, required this.platformY, required this.platformW});
  @override
  void paint(Canvas c, Size s) {
    // platform
    final pp = Paint()..color = const Color(0xFF06D6A0);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(platformX, platformY, platformW, 16),
            const Radius.circular(6)),
        pp);
    // anchor
    if (attached) {
      c.drawCircle(anchor, 6, Paint()..color = Colors.white70);
      c.drawLine(anchor, ball,
          Paint()..color = Colors.white54..strokeWidth = 2);
    }
    // ball
    c.drawCircle(ball, 16, Paint()..color = const Color(0xFFF4A261));
    c.drawCircle(ball, 8, Paint()..color = const Color(0xFFE76F51));
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
