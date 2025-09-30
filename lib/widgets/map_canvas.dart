import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/survey_map_model.dart';
import '../models/annotation_models.dart';
import 'map_painter.dart';

class MapCanvas extends StatefulWidget {
  const MapCanvas({super.key});

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  Offset? _lastPanPosition;
  SmearAnnotation? _draggedSmear;
  Offset? _smearDragOffset;
  EquipmentAnnotation? _draggedIcon;
  Offset? _iconDragOffset;
  final Map<String, ui.Image> _iconCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetView();
      _preloadIcons();
    });
  }

  void _resetView() {
    final model = context.read<SurveyMapModel>();
    final size = MediaQuery.of(context).size;
    model.resetView(Size(size.width * 0.7, size.height));
  }

  Future<void> _preloadIcons() async {
    final model = context.read<SurveyMapModel>();
    for (final icon in model.iconLibrary) {
      if (icon.svgText != null) {
        await _loadSvgToImage(icon.svgText!, icon.file, isAsset: false);
      } else if (icon.assetPath != null) {
        await _loadSvgToImage(icon.assetPath!, icon.file, isAsset: true);
      }
    }
    // Also load equipment icons
    for (final equipment in model.equipment) {
      await _loadSvgToImage(equipment.iconSvg, equipment.iconFile, isAsset: equipment.iconSvg.startsWith('assets/'));
    }
  }

  Future<void> _loadSvgToImage(String svgContent, String key, {required bool isAsset}) async {
    if (_iconCache.containsKey(key)) return;

    try {
      final pictureInfo = await vg.loadPicture(
        isAsset ? SvgAssetLoader(svgContent) : SvgStringLoader(svgContent),
        null,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawPicture(pictureInfo.picture);

      final image = await recorder.endRecording().toImage(
            pictureInfo.size.width.toInt(),
            pictureInfo.size.height.toInt(),
          );

      if (mounted) {
        setState(() {
          _iconCache[key] = image;
        });
      }
    } catch (e) {
      debugPrint('Error loading SVG: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurveyMapModel>(
      builder: (context, model, child) {
        if (!model.hasPdf) {
          return const Center(
            child: Text('No PDF loaded'),
          );
        }

        return GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: (details) => _handleScaleUpdate(details, model),
          onScaleEnd: _handleScaleEnd,
          onTapDown: (details) => _handleTapDown(details, model),
          onSecondaryTapDown: (details) => _handleRightClick(details, model),
          onDoubleTapDown: (details) => _handleDoubleTap(details, model),
          child: MouseRegion(
            cursor: _getCursor(model),
            child: CustomPaint(
              painter: MapPainter(
                model: model,
                iconCache: _iconCache,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }

  MouseCursor _getCursor(SurveyMapModel model) {
    if (_draggedSmear != null || _draggedIcon != null) {
      return SystemMouseCursors.grabbing;
    }

    switch (model.currentTool) {
      case ToolType.smearAdd:
      case ToolType.doseAdd:
      case ToolType.boundary:
        return SystemMouseCursors.precise;
      case ToolType.smearRemove:
      case ToolType.doseRemove:
      case ToolType.boundaryDelete:
      case ToolType.equipmentDelete:
        return SystemMouseCursors.click;
      default:
        return SystemMouseCursors.grab;
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastPanPosition = details.focalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, SurveyMapModel model) {
    if (_draggedSmear != null) {
      _dragSmear(details.focalPoint, model);
      return;
    }

    if (_draggedIcon != null) {
      _dragIcon(details.focalPoint, model);
      return;
    }

    if (model.isResizing) {
      _resizeIcon(details.focalPoint, model);
      return;
    }

    // Handle zoom
    if (details.scale != 1.0) {
      final delta = details.scale > 1.0 ? 1.0 : -1.0;
      final size = MediaQuery.of(context).size;
      model.zoom(delta, details.focalPoint, size);
      _lastPanPosition = details.focalPoint;
      return;
    }

    // Handle pan
    if (_lastPanPosition != null) {
      final delta = details.focalPoint - _lastPanPosition!;
      model.updateOffset(delta);
      _lastPanPosition = details.focalPoint;
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    final model = context.read<SurveyMapModel>();
    _lastPanPosition = null;
    _draggedSmear = null;
    _smearDragOffset = null;
    _draggedIcon = null;
    _iconDragOffset = null;
    model.endResize();
  }

  void _handleTapDown(TapDownDetails details, SurveyMapModel model) {
    final pagePosition = model.canvasToPage(details.localPosition);

    // Handle boundary drawing
    if (model.currentTool == ToolType.boundary) {
      model.addBoundaryPoint(pagePosition);
      return;
    }

    // Handle boundary delete
    if (model.currentTool == ToolType.boundaryDelete) {
      final boundary = model.getBoundaryAtPosition(pagePosition, 15);
      if (boundary != null) {
        model.deleteBoundary(boundary);
      }
      return;
    }

    // Handle annotation addition
    if (model.currentTool == ToolType.smearAdd) {
      model.addSmear(pagePosition);
      return;
    }

    if (model.currentTool == ToolType.doseAdd) {
      model.addDoseRate(pagePosition);
      return;
    }

    // Handle smear removal
    if (model.currentTool == ToolType.smearRemove) {
      final smear = model.getSmearAtPosition(pagePosition, 20);
      if (smear != null) {
        model.removeSmear(smear);
      }
      return;
    }

    // Handle dose removal
    if (model.currentTool == ToolType.doseRemove) {
      final dose = model.getDoseRateAtPosition(pagePosition, 30);
      if (dose != null) {
        model.removeDoseRate(dose);
      }
      return;
    }

    // Handle equipment delete
    if (model.currentTool == ToolType.equipmentDelete) {
      final equipment = model.getEquipmentAtPosition(pagePosition);
      if (equipment != null) {
        model.removeEquipment(equipment);
      }
      return;
    }

    // Handle icon selection and dragging (when no tool active)
    if (model.currentTool == ToolType.none) {
      final equipment = model.getEquipmentAtPosition(pagePosition);
      if (equipment != null) {
        // Check for resize handle
        if (model.selectedIcon == equipment) {
          final handle =
              model.getResizeHandleAtPosition(equipment, pagePosition, model.scale);
          if (handle != null) {
            model.startResize(handle);
            return;
          }
        }

        // Start dragging icon
        model.selectIcon(equipment);
        _draggedIcon = equipment;
        _iconDragOffset = pagePosition - equipment.position;
        return;
      }

      // Check for smear dragging
      final smear = model.getSmearAtPosition(pagePosition, 20);
      if (smear != null) {
        _draggedSmear = smear;
        _smearDragOffset = pagePosition - smear.position;
        return;
      }

      // Clear icon selection
      if (model.selectedIcon != null) {
        model.selectIcon(null);
      }
    }
  }

  void _handleRightClick(TapDownDetails details, SurveyMapModel model) {
    if (model.currentTool == ToolType.boundary) {
      model.removeLastBoundaryPoint();
    }
  }

  void _handleDoubleTap(TapDownDetails details, SurveyMapModel model) {
    if (model.currentTool == ToolType.boundary) {
      model.finishCurrentBoundary();
    }
  }

  void _dragSmear(Offset focalPoint, SurveyMapModel model) {
    if (_draggedSmear == null || _smearDragOffset == null) return;

    final pagePosition = model.canvasToPage(focalPoint);
    final newPosition = pagePosition - _smearDragOffset!;
    model.updateSmearPosition(_draggedSmear!, newPosition);
  }

  void _dragIcon(Offset focalPoint, SurveyMapModel model) {
    if (_draggedIcon == null || _iconDragOffset == null) return;

    final pagePosition = model.canvasToPage(focalPoint);
    final newPosition = pagePosition - _iconDragOffset!;
    model.updateEquipmentPosition(_draggedIcon!, newPosition);
  }

  void _resizeIcon(Offset focalPoint, SurveyMapModel model) {
    if (model.selectedIcon == null || model.resizeHandle == null) return;

    final pagePosition = model.canvasToPage(focalPoint);
    final icon = model.selectedIcon!;
    const minSize = 20.0;
    const maxSize = 200.0;

    double newWidth = icon.width;
    double newHeight = icon.height;

    final aspectRatio = icon.width / icon.height;

    switch (model.resizeHandle!) {
      case ResizeHandle.se:
        newWidth = (pagePosition.dx - (icon.position.dx - icon.width / 2)).abs();
        newHeight = (pagePosition.dy - (icon.position.dy - icon.height / 2)).abs();
        break;
      case ResizeHandle.sw:
        newWidth = ((icon.position.dx + icon.width / 2) - pagePosition.dx).abs();
        newHeight = (pagePosition.dy - (icon.position.dy - icon.height / 2)).abs();
        break;
      case ResizeHandle.ne:
        newWidth = (pagePosition.dx - (icon.position.dx - icon.width / 2)).abs();
        newHeight = ((icon.position.dy + icon.height / 2) - pagePosition.dy).abs();
        break;
      case ResizeHandle.nw:
        newWidth = ((icon.position.dx + icon.width / 2) - pagePosition.dx).abs();
        newHeight = ((icon.position.dy + icon.height / 2) - pagePosition.dy).abs();
        break;
    }

    // Clamp dimensions
    newWidth = newWidth.clamp(minSize, maxSize);
    newHeight = newHeight.clamp(minSize, maxSize);

    // Maintain aspect ratio
    if (newWidth / newHeight > aspectRatio) {
      newWidth = newHeight * aspectRatio;
    } else {
      newHeight = newWidth / aspectRatio;
    }

    model.updateEquipmentSize(icon, newWidth, newHeight);
  }
}
