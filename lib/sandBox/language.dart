// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

// import 'package:citgroupvn_bds/utils/uiUtils.dart';
// import 'package:shimmer/shimmer.dart';

// class MyLang {
//   static BuildContext? context;

//   static demoText() {
//     return UiUtils.getTranslatedLabel(context!, "getCodeBtnLbl");
//   }
// }

// class DottedShimmerPainter extends CustomPainter {
//   final Gradient gradient;
//   final double spacing;

//   DottedShimmerPainter({required this.gradient, required this.spacing});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..style = PaintingStyle.fill
//       ..style = PaintingStyle.fill
//       ..strokeWidth = 2;

//     final dots = List<Offset>.generate(
//       (size.width / spacing).floor() + 1,
//       (int index) => Offset(index * spacing, size.height / 2),
//     );
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }

// class DemoRendererr extends RenderProxyBox {
//   Gradient _gradient;
//   double _percent;
//   @override
//   bool get alwaysNeedsCompositing => child != null;

//   set percent(double newValue) {
//     if (newValue == _percent) {
//       return;
//     }
//     _percent = newValue;
//     markNeedsPaint();
//   }

//   set gradient(Gradient newValue) {
//     if (newValue == _gradient) {
//       return;
//     }
//     _gradient = newValue;
//     markNeedsPaint();
//   }

//   DemoRendererr(
//     this._gradient,
//     this._percent,
//   );

//   @override
//   ShaderMaskLayer? get layer => super.layer as ShaderMaskLayer?;

//   @override
//   void paint(PaintingContext context, Offset offset) {
//     // final painter = DottedShimmerPainter(

//     //   spacing: 3,
//     // );
//     // painter.paint(context.canvas, size);
//   }
// }

// // class DottedShimmer extends StatelessWidget {
// //   final Color color;
// //   final double spacing;

// //   DottedShimmer({this.color = Colors.white, this.spacing = 10});

// //   @override
// //   Widget build(BuildContext context) {
// //     // return RenderProxyBox(

// //     //   child: Container(),
// //     //   onPaint: (context, offset) {
// //     //     final painter = DottedShimmerPainter(
// //     //       color: color,
// //     //       spacing: spacing,
// //     //     );
// //     //     final painterSize = painter.paint(context, offset);
// //     //     return
// //     //   },
// //     // );
// //   }
// // }

// class MyShimmer extends SingleChildRenderObjectWidget {
//   final double percent;
//   final Gradient gradient;

//   const MyShimmer({
//     Widget? child,
//     required this.percent,
//     required this.gradient,
//   }) : super(child: child);

//   @override
//   DemoRendererr createRenderObject(BuildContext context) {
//     return DemoRendererr(gradient, percent);
//   }

//   @override
//   updateRenderObject(context, DemoRendererr obj) {}
// }

// ///
// /// * author: hunghd
// /// * email: hunghd.yb@gmail.com
// ///
// /// A package provides an easy way to add shimmer effect to Flutter application
// ///

// @immutable
// class Shimmer extends StatefulWidget {
//   final Widget child;
//   final Duration period;
//   final ShimmerDirection direction;
//   final Gradient gradient;
//   final int loop;
//   final bool enabled;

//   const Shimmer({
//     Key? key,
//     required this.child,
//     required this.gradient,
//     this.direction = ShimmerDirection.ltr,
//     this.period = const Duration(milliseconds: 1500),
//     this.loop = 0,
//     this.enabled = true,
//   }) : super(key: key);

//   ///
//   /// A convenient constructor provides an easy and convenient way to create a
//   /// [Shimmer] which [gradient] is [LinearGradient] made up of `baseColor` and
//   /// `highlightColor`.
//   ///
//   Shimmer.fromColors({
//     Key? key,
//     required this.child,
//     required Color baseColor,
//     required Color highlightColor,
//     this.period = const Duration(milliseconds: 1500),
//     this.direction = ShimmerDirection.ltr,
//     this.loop = 0,
//     this.enabled = true,
//   })  : gradient = LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.centerRight,
//             colors: <Color>[
//               baseColor,
//               baseColor,
//               highlightColor,
//               baseColor,
//               baseColor
//             ],
//             stops: const <double>[
//               0.0,
//               0.35,
//               0.5,
//               0.65,
//               1.0
//             ]),
//         super(key: key);

//   @override
//   _ShimmerState createState() => _ShimmerState();

//   @override
//   void debugFillProperties(DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(properties);
//     properties.add(DiagnosticsProperty<Gradient>('gradient', gradient,
//         defaultValue: null));
//     properties.add(EnumProperty<ShimmerDirection>('direction', direction));
//     properties.add(
//         DiagnosticsProperty<Duration>('period', period, defaultValue: null));
//     properties
//         .add(DiagnosticsProperty<bool>('enabled', enabled, defaultValue: null));
//     properties.add(DiagnosticsProperty<int>('loop', loop, defaultValue: 0));
//   }
// }

// class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   int _count = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: widget.period)
//       ..addStatusListener((AnimationStatus status) {
//         if (status != AnimationStatus.completed) {
//           return;
//         }
//         _count++;
//         if (widget.loop <= 0) {
//           _controller.repeat();
//         } else if (_count < widget.loop) {
//           _controller.forward(from: 0.0);
//         }
//       });
//     if (widget.enabled) {
//       _controller.forward();
//     }
//   }

//   @override
//   void didUpdateWidget(Shimmer oldWidget) {
//     if (widget.enabled) {
//       _controller.forward();
//     } else {
//       _controller.stop();
//     }
//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       child: widget.child,
//       builder: (BuildContext context, Widget? child) => _Shimmer(
//         direction: widget.direction,
//         gradient: widget.gradient,
//         percent: _controller.value,
//         child: child,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

// @immutable
// class _Shimmer extends SingleChildRenderObjectWidget {
//   final double percent;
//   final ShimmerDirection direction;
//   final Gradient gradient;

//   const _Shimmer({
//     Widget? child,
//     required this.percent,
//     required this.direction,
//     required this.gradient,
//   }) : super(child: child);

//   @override
//   _ShimmerFilter createRenderObject(BuildContext context) {
//     return _ShimmerFilter(percent, direction, gradient);
//   }

//   @override
//   void updateRenderObject(BuildContext context, _ShimmerFilter shimmer) {
//     shimmer.percent = percent;
//     shimmer.gradient = gradient;
//     shimmer.direction = direction;
//   }
// }

// class _ShimmerFilter extends RenderProxyBox {
//   ShimmerDirection _direction;
//   Gradient _gradient;
//   double _percent;

//   _ShimmerFilter(this._percent, this._direction, this._gradient);

//   @override
//   ShaderMaskLayer? get layer => super.layer as ShaderMaskLayer?;

//   @override
//   bool get alwaysNeedsCompositing => child != null;

//   set percent(double newValue) {
//     if (newValue == _percent) {
//       return;
//     }
//     _percent = newValue;
//     markNeedsPaint();
//   }

//   set gradient(Gradient newValue) {
//     if (newValue == _gradient) {
//       return;
//     }
//     _gradient = newValue;
//     markNeedsPaint();
//   }

//   set direction(ShimmerDirection newDirection) {
//     if (newDirection == _direction) {
//       return;
//     }
//     _direction = newDirection;
//     markNeedsLayout();
//   }

//   @override
//   void paint(PaintingContext context, Offset offset) {
//     if (child != null) {
//       assert(needsCompositing);

//       final double width = child!.size.width;
//       final double height = child!.size.height;
//       Rect rect;
//       double dx, dy;
//       if (_direction == ShimmerDirection.rtl) {
//         dx = _offset(width, -width, _percent);
//         dy = 0.0;
//         rect = Rect.fromLTWH(dx - width, dy, 3 * width, height);
//       } else if (_direction == ShimmerDirection.ttb) {
//         dx = 0.0;
//         dy = _offset(-height, height, _percent);
//         rect = Rect.fromLTWH(dx, dy - height, width, 3 * height);
//       } else if (_direction == ShimmerDirection.btt) {
//         dx = 0.0;
//         dy = _offset(height, -height, _percent);
//         rect = Rect.fromLTWH(dx, dy - height, width, 3 * height);
//       } else {
//         dx = _offset(-width, width, _percent);
//         dy = 0.0;
//         rect = Rect.fromLTWH(dx - width, dy, 3 * width, height);
//       }

//       var dottedShimmerPainter =
//           DottedShimmerPainter(gradient: _gradient, spacing: 4);
//       dottedShimmerPainter.paint(context.canvas, size);
//       // layer ??= ShaderMaskLayer();
//       // layer!
//       //   ..shader = _gradient.createShader(rect)
//       //   ..maskRect = offset & size
//       //   ..blendMode = BlendMode.srcIn;

//       // context.pushLayer(layer!, super.paint, offset);
//     } else {
//       layer = null;
//     }
//   }

//   double _offset(double start, double end, double percent) {
//     return start + (end - start) * percent;
//   }
// }
