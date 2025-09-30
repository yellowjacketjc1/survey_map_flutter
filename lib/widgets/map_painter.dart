import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/annotation_models.dart';
import '../models/survey_map_model.dart';

class MapPainter extends CustomPainter {
  final SurveyMapModel model;
  final Map<String, ui.Image> iconCache;

  MapPainter({
    required this.model,
    required this.iconCache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (model.pdfImage == null) return;

    canvas.save();

    // Apply offset
    canvas.translate(model.offset.dx, model.offset.dy);

    // Apply rotation around center
    final centerX = model.pdfSize.width / 2;
    final centerY = model.pdfSize.height / 2;
    canvas.translate(centerX * model.scale, centerY * model.scale);
    canvas.rotate(model.rotation * 3.14159265359 / 180);
    canvas.translate(-centerX * model.scale, -centerY * model.scale);

    // Apply scale
    canvas.scale(model.scale);

    // Draw PDF
    canvas.drawImage(model.pdfImage!, Offset.zero, Paint());

    canvas.restore();

    // Draw annotations (in page coordinates but transformed)
    _drawAnnotations(canvas);
  }

  void _drawAnnotations(Canvas canvas) {
    canvas.save();
    canvas.translate(model.offset.dx, model.offset.dy);
    canvas.scale(model.scale);

    // Draw smears
    for (final smear in model.smears) {
      _drawSmear(canvas, smear);
    }

    // Draw dose rates
    for (final dose in model.doseRates) {
      _drawDoseRate(canvas, dose);
    }

    // Draw equipment
    for (final equipment in model.equipment) {
      _drawEquipment(canvas, equipment);
    }

    // Draw boundaries
    for (final boundary in model.boundaries) {
      _drawBoundary(canvas, boundary);
    }

    // Draw current boundary being drawn
    if (model.currentBoundary != null &&
        model.currentBoundary!.points.isNotEmpty) {
      _drawCurrentBoundary(canvas, model.currentBoundary!);
    }

    canvas.restore();
  }

  void _drawSmear(Canvas canvas, SmearAnnotation smear) {
    final paint = Paint()
      ..color = const Color(0x99FFC107)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(smear.position, 15, paint);
    canvas.drawCircle(smear.position, 15, strokePaint);

    // Draw ID
    final textPainter = TextPainter(
      text: TextSpan(
        text: smear.id.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        smear.position.dx - textPainter.width / 2,
        smear.position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawDoseRate(Canvas canvas, DoseRateAnnotation dose) {
    final displayValue = '${dose.value} ${dose.unit}';

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayValue,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Draw neutron indicator if needed
    if (dose.type == DoseType.neutron) {
      final dotX = dose.position.dx - (textPainter.width / 2) - 8;
      final dotPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dose.position.dy), 3, dotPaint);
    }

    textPainter.paint(
      canvas,
      Offset(
        dose.position.dx - textPainter.width / 2,
        dose.position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawEquipment(Canvas canvas, EquipmentAnnotation equipment) {
    // Try to get cached image
    final cachedImage = iconCache[equipment.iconFile];

    if (cachedImage != null) {
      canvas.save();

      // Apply rotation if needed
      if (equipment.rotation != 0) {
        canvas.translate(equipment.position.dx, equipment.position.dy);
        canvas.rotate(equipment.rotation * 3.14159265359 / 180);
        canvas.translate(-equipment.position.dx, -equipment.position.dy);
      }

      // Draw the image
      final rect = Rect.fromCenter(
        center: equipment.position,
        width: equipment.width,
        height: equipment.height,
      );
      canvas.drawImageRect(
        cachedImage,
        Rect.fromLTWH(
          0,
          0,
          cachedImage.width.toDouble(),
          cachedImage.height.toDouble(),
        ),
        rect,
        Paint(),
      );

      canvas.restore();

      // Draw selection handles if selected
      if (model.selectedIcon == equipment) {
        _drawSelectionHandles(canvas, equipment);
      }
    } else {
      // Draw placeholder
      final rect = Rect.fromCenter(
        center: equipment.position,
        width: equipment.width,
        height: equipment.height,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawSelectionHandles(Canvas canvas, EquipmentAnnotation equipment) {
    final halfWidth = equipment.width / 2;
    final halfHeight = equipment.height / 2;
    const handleSize = 6.0;
    const margin = 5.0;

    // Draw selection border
    final rect = Rect.fromCenter(
      center: equipment.position,
      width: equipment.width + margin * 2,
      height: equipment.height + margin * 2,
    );

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(rect, borderPaint);

    // Draw resize handles
    final handlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final handles = [
      Offset(equipment.position.dx - halfWidth - margin,
          equipment.position.dy - halfHeight - margin),
      Offset(equipment.position.dx + halfWidth + margin,
          equipment.position.dy - halfHeight - margin),
      Offset(equipment.position.dx - halfWidth - margin,
          equipment.position.dy + halfHeight + margin),
      Offset(equipment.position.dx + halfWidth + margin,
          equipment.position.dy + halfHeight + margin),
    ];

    for (final handle in handles) {
      canvas.drawRect(
        Rect.fromCenter(center: handle, width: handleSize, height: handleSize),
        handlePaint,
      );
    }
  }

  void _drawBoundary(Canvas canvas, BoundaryAnnotation boundary) {
    if (boundary.points.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFF6F42C1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(boundary.points[0].dx, boundary.points[0].dy);
    for (int i = 1; i < boundary.points.length; i++) {
      path.lineTo(boundary.points[i].dx, boundary.points[i].dy);
    }

    // Draw dashed line
    _drawDashedPath(canvas, path, paint, const [8.0, 4.0]);
  }

  void _drawCurrentBoundary(Canvas canvas, BoundaryAnnotation boundary) {
    if (boundary.points.isEmpty) return;

    // Draw lines
    if (boundary.points.length > 1) {
      final paint = Paint()
        ..color = const Color(0xFF8A63D2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final path = Path();
      path.moveTo(boundary.points[0].dx, boundary.points[0].dy);
      for (int i = 1; i < boundary.points.length; i++) {
        path.lineTo(boundary.points[i].dx, boundary.points[i].dy);
      }

      _drawDashedPath(canvas, path, paint, const [8.0, 4.0]);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF6F42C1)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final point in boundary.points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(point, 4, strokePaint);
    }
  }

  void _drawDashedPath(
      Canvas canvas, Path path, Paint paint, List<double> pattern) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      bool draw = true;
      int patternIndex = 0;

      while (distance < metric.length) {
        final length = pattern[patternIndex % pattern.length];
        if (draw) {
          final extractPath = metric.extractPath(distance, distance + length);
          canvas.drawPath(extractPath, paint);
        }
        distance += length;
        draw = !draw;
        patternIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return true; // Always repaint for simplicity
  }
}
