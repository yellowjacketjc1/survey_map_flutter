import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart' as vg_lib;
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
  Offset? _gestureStartPosition;
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
      // Skip Material Icons - they're rendered differently
      if (icon.metadata is Map && icon.metadata['type'] == 'material') {
        final iconData = icon.metadata['iconData'] as IconData;
        await _loadMaterialIconToImage(iconData, icon.file);
        continue;
      }

      if (icon.svgText != null) {
        await _loadSvgToImage(icon.svgText!, icon.file, isAsset: false);
      } else if (icon.assetPath != null) {
        await _loadSvgToImage(icon.assetPath!, icon.file, isAsset: true);
      }
    }
    // Also load equipment icons
    for (final equipment in model.equipment) {
      // Skip if already cached
      if (_iconCache.containsKey(equipment.iconFile)) continue;

      // Check if it's a Material Icon
      if (equipment.iconSvg.startsWith('material:')) {
        // Extract the icon key and load from icon library
        final materialIcon = model.iconLibrary.firstWhere(
          (icon) => icon.file == equipment.iconFile,
          orElse: () => throw Exception('Material icon not found: ${equipment.iconFile}'),
        );
        final iconData = materialIcon.metadata['iconData'] as IconData;
        await _loadMaterialIconToImage(iconData, equipment.iconFile);
      } else {
        // Determine if it's an asset path or inline SVG
        final isAsset = equipment.iconSvg.startsWith('assets/') ||
                        equipment.iconSvg.contains('.svg');
        await _loadSvgToImage(equipment.iconSvg, equipment.iconFile, isAsset: isAsset);
      }
    }
  }

  Future<void> _loadMaterialIconToImage(IconData iconData, String key) async {
    if (_iconCache.containsKey(key)) return;

    try {
      debugPrint('Loading Material Icon: $key');

      const size = 100.0; // Base size for the icon
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Create a text painter to render the icon
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(iconData.codePoint),
          style: TextStyle(
            fontSize: size,
            fontFamily: iconData.fontFamily,
            package: iconData.fontPackage,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset.zero);

      final image = await recorder.endRecording().toImage(
            textPainter.width.toInt(),
            textPainter.height.toInt(),
          );

      if (mounted) {
        setState(() {
          _iconCache[key] = image;
        });
        debugPrint('Material Icon cached: $key');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading Material Icon $key: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadSvgToImage(String svgContent, String key, {required bool isAsset}) async {
    if (_iconCache.containsKey(key)) return;

    try {
      debugPrint('Loading SVG: $key (isAsset: $isAsset)');

      final pictureInfo = await vg_lib.vg.loadPicture(
        isAsset ? SvgAssetLoader(svgContent) : SvgStringLoader(svgContent),
        null,
      );

      debugPrint('SVG loaded, size: ${pictureInfo.size}');

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
        debugPrint('SVG cached: $key');
      }

      pictureInfo.picture.dispose();
    } catch (e, stackTrace) {
      debugPrint('Error loading SVG $key: $e');
      debugPrint('Stack trace: $stackTrace');
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

        return DragTarget<IconMetadata>(
          onAcceptWithDetails: (details) => _handleIconDrop(details, model),
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTapDown: (details) => _handleTapDown(details, model),
              onScaleStart: _handleScaleStart,
              onScaleUpdate: (details) => _handleScaleUpdate(details, model),
              onScaleEnd: _handleScaleEnd,
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

  void _handleTapDown(TapDownDetails details, SurveyMapModel model) {
    final pagePosition = model.canvasToPage(details.localPosition);

    debugPrint('TapDown: tool=${model.currentTool}');

    // Handle equipment delete on tap
    if (model.currentTool == ToolType.equipmentDelete) {
      final equipment = model.getEquipmentAtPosition(pagePosition);
      if (equipment != null) {
        debugPrint('✓ Deleted: ${equipment.iconFile}');
        model.removeEquipment(equipment);
      } else {
        debugPrint('✗ No icon at tap position (${model.equipment.length} total)');
      }
      return;
    }

    // Handle other tool taps
    _gestureStartPosition = details.localPosition;
    _lastPanPosition = details.localPosition;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    final model = context.read<SurveyMapModel>();
    final pagePosition = model.canvasToPage(details.focalPoint);

    if (model.currentTool == ToolType.equipmentDelete) {
      debugPrint('ScaleStart detected');
    }

    // Store positions for tap/drag detection
    _gestureStartPosition = details.focalPoint;
    _lastPanPosition = details.focalPoint;


    // Only check for dragging when no tool is active
    if (model.currentTool == ToolType.none) {
      // Check for icon resize handle
      if (model.selectedIcon != null) {
        final handle = model.getResizeHandleAtPosition(
          model.selectedIcon!,
          pagePosition,
          model.scale,
        );
        if (handle != null) {
          model.startResize(handle);
          debugPrint('Resize handle grabbed');
          return;
        }
      }

      // Check for icon drag
      final equipment = model.getEquipmentAtPosition(pagePosition);
      if (equipment != null) {
        model.selectIcon(equipment);
        _draggedIcon = equipment;
        _iconDragOffset = pagePosition - equipment.position;
        return;
      }

      // Check for smear drag
      final smear = model.getSmearAtPosition(pagePosition, 20);
      if (smear != null) {
        _draggedSmear = smear;
        _smearDragOffset = pagePosition - smear.position;
        debugPrint('Smear drag started');
        return;
      }
    }
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

    // Handle pan - only when no tool is active or when using pan-compatible tools
    if (_lastPanPosition != null && model.currentTool == ToolType.none) {
      final delta = details.focalPoint - _lastPanPosition!;
      model.updateOffset(delta);
      _lastPanPosition = details.focalPoint;
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    final model = context.read<SurveyMapModel>();

    // Check if this was a tap (no significant movement)
    final wasDragging = _draggedSmear != null || _draggedIcon != null || model.isResizing;

    bool isTap = false;
    double distance = 0;
    if (_gestureStartPosition != null) {
      if (_lastPanPosition != null) {
        distance = (_lastPanPosition! - _gestureStartPosition!).distance;
        // If moved less than 20 pixels, consider it a tap (very forgiving threshold)
        isTap = distance < 20.0;
      } else {
        // If _lastPanPosition is null, it means no pan occurred, so it's definitely a tap
        isTap = true;
      }
    }

    if (model.currentTool == ToolType.equipmentDelete) {
      debugPrint('ScaleEnd: drag=$wasDragging, dist=${distance.toStringAsFixed(1)}px, tap=$isTap');
    }

    if (!wasDragging && isTap) {
      // This was a tap, not a drag - handle tool actions
      _handleTap(model);
    }

    _gestureStartPosition = null;
    _lastPanPosition = null;
    _draggedSmear = null;
    _smearDragOffset = null;
    _draggedIcon = null;
    _iconDragOffset = null;
    model.endResize();
  }

  void _handleTap(SurveyMapModel model) {
    if (_gestureStartPosition == null) return;

    final pagePosition = model.canvasToPage(_gestureStartPosition!);

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
        debugPrint('✓ Deleted: ${equipment.iconFile}');
        model.removeEquipment(equipment);
      } else {
        debugPrint('✗ No icon at click position (${model.equipment.length} total icons)');
      }
      return;
    }

    // Handle icon selection when no tool active
    if (model.currentTool == ToolType.none) {
      final equipment = model.getEquipmentAtPosition(pagePosition);
      if (equipment != null) {
        model.selectIcon(equipment);
      } else {
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

  void _handleIconDrop(DragTargetDetails<IconMetadata> details, SurveyMapModel model) {
    final icon = details.data;
    final dropPosition = details.offset;

    // Convert screen position to page position
    final pagePosition = model.canvasToPage(dropPosition);

    // Get icon content
    String iconContent = '';
    bool isAsset = false;
    if (icon.metadata is Map && icon.metadata['type'] == 'material') {
      iconContent = 'material:${icon.file}';
    } else {
      iconContent = icon.svgText ?? '';
      if (iconContent.isEmpty && icon.assetPath != null) {
        iconContent = icon.assetPath!;
        isAsset = true;
      }
    }

    // Add equipment at drop position
    final equipment = EquipmentAnnotation(
      position: pagePosition,
      iconFile: icon.file,
      iconSvg: iconContent,
      width: 80,
      height: 80,
    );

    model.addEquipment(equipment);

    // Load the icon for this equipment
    if (icon.metadata is Map && icon.metadata['type'] == 'material') {
      final iconData = icon.metadata['iconData'] as IconData;
      _loadMaterialIconToImage(iconData, icon.file);
    } else {
      _loadSvgToImage(iconContent, icon.file, isAsset: isAsset);
    }

    debugPrint('Equipment added: file=${equipment.iconFile}, page pos=$pagePosition, width=${equipment.width}, height=${equipment.height}');
    debugPrint('Total equipment now: ${model.equipment.length}');
  }

  void _dragSmear(Offset focalPoint, SurveyMapModel model) {
    if (_draggedSmear == null || _smearDragOffset == null) return;

    final pagePosition = model.canvasToPage(focalPoint);
    final newPosition = pagePosition - _smearDragOffset!;
    model.updateSmearPosition(_draggedSmear!, newPosition);
  }

  void _dragIcon(Offset focalPoint, SurveyMapModel model) {
    if (_draggedIcon == null || _iconDragOffset == null) {
      debugPrint('_dragIcon called but _draggedIcon or _iconDragOffset is null');
      return;
    }

    final pagePosition = model.canvasToPage(focalPoint);
    final newPosition = pagePosition - _iconDragOffset!;

    model.updateEquipmentPosition(_draggedIcon!, newPosition);

    // Update the _draggedIcon reference to the updated equipment (which is now selectedIcon)
    _draggedIcon = model.selectedIcon;
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
