import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart' as vg_lib;
import '../models/survey_map_model.dart';
import '../models/annotation_models.dart';
import '../models/commands.dart';
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
  Offset? _smearDragStartPosition;
  DoseRateAnnotation? _draggedDoseRate;
  Offset? _doseRateDragOffset;
  Offset? _doseRateDragStartPosition;
  EquipmentAnnotation? _draggedIcon;
  Offset? _iconDragOffset;
  Offset? _iconDragStartPosition;
  CommentAnnotation? _draggedComment;
  Offset? _commentDragOffset;
  Offset? _commentDragStartPosition;
  bool _draggedTitleCard = false;
  Offset? _titleCardDragOffset;
  Offset? _titleCardDragStartPosition;
  final Map<String, ui.Image> _iconCache = {};
  double _lastScale = 1.0;

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
            return Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  _handleScrollZoom(event, model);
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _handleTapDown(details, model),
                onTapUp: (details) => _handleTapUp(details, model),
                onScaleStart: _handleScaleStart,
                onScaleUpdate: (details) => _handleScaleUpdate(details, model),
                onScaleEnd: _handleScaleEnd,
                onSecondaryTapDown: (details) {
                  // Prevent default context menu and handle right-click
                  _handleRightClick(details, model);
                },
                onDoubleTap: () => _handleDoubleTapForEdit(model),
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
              ),
            );
          },
        );
      },
    );
  }

  MouseCursor _getCursor(SurveyMapModel model) {
    if (_draggedSmear != null || _draggedDoseRate != null || _draggedIcon != null || _draggedComment != null) {
      return SystemMouseCursors.grabbing;
    }

    switch (model.currentTool) {
      case ToolType.smearAdd:
      case ToolType.doseAdd:
      case ToolType.boundary:
      case ToolType.commentAdd:
        return SystemMouseCursors.precise;
      case ToolType.smearRemove:
      case ToolType.doseRemove:
      case ToolType.boundaryDelete:
      case ToolType.equipmentDelete:
      case ToolType.commentRemove:
        return SystemMouseCursors.click;
      default:
        return SystemMouseCursors.grab;
    }
  }

  void _handleScrollZoom(PointerScrollEvent event, SurveyMapModel model) {
    // Skip trackpad events due to Flutter framework assertion bug
    // This is a known issue in Flutter web with trackpad scrolling
    if (event.kind == PointerDeviceKind.trackpad) {
      return;
    }

    // Calculate zoom delta from scroll
    final scrollDelta = event.scrollDelta.dy;

    // Invert scroll direction for natural zoom (scroll up = zoom in)
    final zoomDelta = -scrollDelta / 100.0;

    final size = MediaQuery.of(context).size;
    model.zoom(zoomDelta, event.localPosition, size);
  }

  void _handleTapDown(TapDownDetails details, SurveyMapModel model) {
    debugPrint('TapDown: tool=${model.currentTool}');
    _gestureStartPosition = details.localPosition;
    _lastPanPosition = details.localPosition;
  }

  void _handleTapUp(TapUpDetails details, SurveyMapModel model) {
    debugPrint('TapUp: tool=${model.currentTool}');

    if (_gestureStartPosition == null) return;

    // Check if this was a simple tap (not a drag)
    final distance = (details.localPosition - _gestureStartPosition!).distance;
    if (distance > 10) {
      debugPrint('TapUp: Movement detected ($distance px), ignoring as tap');
      return;
    }

    final pagePosition = model.canvasToPage(details.localPosition);
    debugPrint('TapUp: Handling as tap at $pagePosition');

    // Handle equipment delete
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

    // Handle boundary drawing
    if (model.currentTool == ToolType.boundary) {
      debugPrint('Adding boundary point');
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
      debugPrint('Adding smear at $pagePosition');
      model.addSmear(pagePosition);
      return;
    }

    if (model.currentTool == ToolType.doseAdd) {
      debugPrint('Adding dose rate at $pagePosition');
      model.addDoseRate(pagePosition);
      return;
    }

    if (model.currentTool == ToolType.commentAdd) {
      debugPrint('Adding comment at $pagePosition');
      _showAddCommentDialog(model, pagePosition);
      return;
    }

    // Handle smear removal
    if (model.currentTool == ToolType.smearRemove) {
      final smear = model.getSmearAtPosition(pagePosition, 40 / model.scale);
      if (smear != null) {
        model.removeSmear(smear);
      }
      return;
    }

    // Handle dose removal
    if (model.currentTool == ToolType.doseRemove) {
      final dose = model.getDoseRateAtPosition(pagePosition, 50 / model.scale);
      if (dose != null) {
        model.removeDoseRate(dose);
      }
      return;
    }

    // Handle comment removal
    if (model.currentTool == ToolType.commentRemove) {
      final comment = model.getCommentAtPosition(pagePosition, 40 / model.scale);
      if (comment != null) {
        model.removeComment(comment);
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

  void _handleScaleStart(ScaleStartDetails details) {
    final model = context.read<SurveyMapModel>();
    final pagePosition = model.canvasToPage(details.focalPoint);

    debugPrint('ScaleStart: tool=${model.currentTool}, pos=${details.focalPoint}');

    // Store positions for tap/drag detection
    _gestureStartPosition = details.focalPoint;
    _lastPanPosition = details.focalPoint;
    _lastScale = 1.0;


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

      // Check for title card drag
      if (model.isTitleCardAtPosition(pagePosition)) {
        _draggedTitleCard = true;
        _titleCardDragOffset = pagePosition - model.titleCard!.position;
        _titleCardDragStartPosition = model.titleCard!.position;
        debugPrint('Title card drag started');
        return;
      }

      // Check for icon drag
      final equipment = model.getEquipmentAtPosition(pagePosition);
      if (equipment != null) {
        model.selectIcon(equipment);
        _draggedIcon = equipment;
        _iconDragOffset = pagePosition - equipment.position;
        _iconDragStartPosition = equipment.position;
        return;
      }

      // Check for smear drag (increased threshold for easier grabbing)
      final smear = model.getSmearAtPosition(pagePosition, 40 / model.scale);
      if (smear != null) {
        _draggedSmear = smear;
        _smearDragOffset = pagePosition - smear.position;
        _smearDragStartPosition = smear.position;
        debugPrint('Smear drag started: ${smear.position}');
        return;
      }

      // Check for dose rate drag (increased threshold for easier grabbing)
      final doseRate = model.getDoseRateAtPosition(pagePosition, 50 / model.scale);
      if (doseRate != null) {
        _draggedDoseRate = doseRate;
        _doseRateDragOffset = pagePosition - doseRate.position;
        _doseRateDragStartPosition = doseRate.position;
        debugPrint('Dose rate drag started: ${doseRate.position}');
        return;
      }

      // Check for comment drag (increased threshold for easier grabbing)
      final comment = model.getCommentAtPosition(pagePosition, 40 / model.scale);
      if (comment != null) {
        _draggedComment = comment;
        _commentDragOffset = pagePosition - comment.position;
        _commentDragStartPosition = comment.position;
        debugPrint('Comment drag started: ${comment.position}');
        return;
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, SurveyMapModel model) {
    debugPrint('ScaleUpdate: pointers=${details.pointerCount}, scale=${details.scale}, focal=${details.focalPoint}');

    if (_draggedTitleCard) {
      _dragTitleCard(details.focalPoint, model);
      return;
    }

    if (_draggedSmear != null) {
      _dragSmear(details.focalPoint, model);
      return;
    }

    if (_draggedDoseRate != null) {
      _dragDoseRate(details.focalPoint, model);
      return;
    }

    if (_draggedIcon != null) {
      _dragIcon(details.focalPoint, model);
      return;
    }

    if (_draggedComment != null) {
      _dragComment(details.focalPoint, model);
      return;
    }

    if (model.isResizing) {
      _resizeIcon(details.focalPoint, model);
      return;
    }

    // Handle pinch-to-zoom
    if (details.scale != 1.0 && details.pointerCount >= 2) {
      // Calculate zoom change from last scale value
      final scaleDelta = details.scale - _lastScale;

      // Convert to zoom delta (similar to mouse wheel)
      // Multiply by a factor to make pinch zoom more responsive
      final zoomDelta = scaleDelta * 10.0;

      final size = MediaQuery.of(context).size;
      model.zoom(zoomDelta, details.focalPoint, size);

      _lastScale = details.scale;
      _lastPanPosition = details.focalPoint;
      return;
    }

    // Handle pan - only when no tool is active or when using pan-compatible tools
    if (_lastPanPosition != null && model.currentTool == ToolType.none && details.pointerCount == 1) {
      final delta = details.focalPoint - _lastPanPosition!;
      model.updateOffset(delta);
    }

    // Always update last position for distance tracking (but don't use for panning unless tool is none)
    _lastPanPosition = details.focalPoint;
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    final model = context.read<SurveyMapModel>();

    // Check if this was a tap (no significant movement)
    final wasDragging = _draggedSmear != null || _draggedDoseRate != null || _draggedIcon != null || _draggedComment != null || _draggedTitleCard || model.isResizing;

    bool isTap = false;
    double distance = 0;
    if (_gestureStartPosition != null) {
      if (_lastPanPosition != null) {
        distance = (_lastPanPosition! - _gestureStartPosition!).distance;
        // If moved less than 5 pixels, consider it a tap (more strict for better tap detection)
        isTap = distance < 5.0;
      } else {
        // If _lastPanPosition is null, it means no pan occurred, so it's definitely a tap
        isTap = true;
      }
    }

    debugPrint('ScaleEnd: drag=$wasDragging, dist=${distance.toStringAsFixed(1)}px, tap=$isTap, tool=${model.currentTool}');

    // Create undo/redo commands for completed drags
    if (_draggedSmear != null && _smearDragStartPosition != null && _draggedSmear!.position != _smearDragStartPosition) {
      debugPrint('Smear dragged from $_smearDragStartPosition to ${_draggedSmear!.position}');
      // Add command to undo stack without executing (position already updated via Direct methods)
      model.undoRedoManager.addCommandWithoutExecuting(
        MoveSmearCommand(model, _draggedSmear!, _smearDragStartPosition!, _draggedSmear!.position)
      );
    }

    if (_draggedDoseRate != null && _doseRateDragStartPosition != null && _draggedDoseRate!.position != _doseRateDragStartPosition) {
      debugPrint('Dose rate dragged from $_doseRateDragStartPosition to ${_draggedDoseRate!.position}');
      // Add command to undo stack without executing (position already updated via Direct methods)
      model.undoRedoManager.addCommandWithoutExecuting(
        MoveDoseRateCommand(model, _draggedDoseRate!, _doseRateDragStartPosition!, _draggedDoseRate!.position)
      );
    }

    if (_draggedIcon != null && _iconDragStartPosition != null && _draggedIcon!.position != _iconDragStartPosition) {
      debugPrint('Icon dragged from $_iconDragStartPosition to ${_draggedIcon!.position}');
      // Add command to undo stack without executing (position already updated via Direct methods)
      model.undoRedoManager.addCommandWithoutExecuting(
        MoveEquipmentCommand(model, _draggedIcon!, _iconDragStartPosition!, _draggedIcon!.position)
      );
    }

    if (_draggedComment != null && _commentDragStartPosition != null && _draggedComment!.position != _commentDragStartPosition) {
      debugPrint('Comment dragged from $_commentDragStartPosition to ${_draggedComment!.position}');
      // Add command to undo stack without executing (position already updated via Direct methods)
      model.undoRedoManager.addCommandWithoutExecuting(
        MoveCommentCommand(model, _draggedComment!, _commentDragStartPosition!, _draggedComment!.position)
      );
    }

    // Always handle tap if it's a tap gesture and not dragging
    if (!wasDragging && isTap) {
      // This was a tap, not a drag - handle tool actions
      _handleTap(model);
    }

    _gestureStartPosition = null;
    _lastPanPosition = null;
    _draggedSmear = null;
    _smearDragOffset = null;
    _smearDragStartPosition = null;
    _draggedDoseRate = null;
    _doseRateDragOffset = null;
    _doseRateDragStartPosition = null;
    _draggedIcon = null;
    _iconDragOffset = null;
    _iconDragStartPosition = null;
    _draggedComment = null;
    _commentDragOffset = null;
    _commentDragStartPosition = null;
    _draggedTitleCard = false;
    _titleCardDragOffset = null;
    _titleCardDragStartPosition = null;
    _lastScale = 1.0;
    model.endResize();
  }

  void _handleTap(SurveyMapModel model) {
    if (_gestureStartPosition == null) {
      debugPrint('_handleTap: gestureStartPosition is null');
      return;
    }

    final pagePosition = model.canvasToPage(_gestureStartPosition!);
    debugPrint('_handleTap called: tool=${model.currentTool}, pagePos=$pagePosition');

    // Handle boundary drawing
    if (model.currentTool == ToolType.boundary) {
      debugPrint('Adding boundary point');
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
      debugPrint('Adding smear at $pagePosition');
      model.addSmear(pagePosition);
      return;
    }

    if (model.currentTool == ToolType.doseAdd) {
      debugPrint('Adding dose rate at $pagePosition');
      model.addDoseRate(pagePosition);
      return;
    }

    // Handle smear removal
    if (model.currentTool == ToolType.smearRemove) {
      final smear = model.getSmearAtPosition(pagePosition, 40 / model.scale);
      if (smear != null) {
        model.removeSmear(smear);
      }
      return;
    }

    // Handle dose removal
    if (model.currentTool == ToolType.doseRemove) {
      final dose = model.getDoseRateAtPosition(pagePosition, 50 / model.scale);
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

    // Handle comment addition
    if (model.currentTool == ToolType.commentAdd) {
      debugPrint('Comment add detected! Position: $pagePosition');
      _showAddCommentDialog(model, pagePosition);
      return;
    }

    // Handle comment removal
    if (model.currentTool == ToolType.commentRemove) {
      final comment = model.getCommentAtPosition(pagePosition, 40 / model.scale);
      if (comment != null) {
        model.removeComment(comment);
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
    final pagePosition = model.canvasToPage(details.localPosition);

    // Check if right-clicked on a dose rate (scale-aware threshold)
    final doseRate = model.getDoseRateAtPosition(pagePosition, 50 / model.scale);
    if (doseRate != null) {
      _showEditDoseRateDialog(model, doseRate);
      return;
    }

    // Handle boundary undo point
    if (model.currentTool == ToolType.boundary) {
      model.removeLastBoundaryPoint();
    }
  }

  void _handleDoubleTapForEdit(SurveyMapModel model) {
    if (_gestureStartPosition == null) return;

    final pagePosition = model.canvasToPage(_gestureStartPosition!);

    // Check if double-clicked on a comment (scale-aware threshold)
    final comment = model.getCommentAtPosition(pagePosition, 40 / model.scale);
    if (comment != null) {
      _showEditCommentDialog(model, comment);
      return;
    }

    // Check if double-clicked on a dose rate (scale-aware threshold)
    final doseRate = model.getDoseRateAtPosition(pagePosition, 50 / model.scale);
    if (doseRate != null) {
      _showEditDoseRateDialog(model, doseRate);
      return;
    }

    // Handle boundary double-click (finish drawing)
    if (model.currentTool == ToolType.boundary) {
      model.finishCurrentBoundary();
    }
  }

  void _showEditDoseRateDialog(SurveyMapModel model, DoseRateAnnotation doseRate) {
    final valueController = TextEditingController(text: doseRate.value.toString());
    String selectedUnit = doseRate.unit;
    DoseType selectedType = doseRate.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Dose Rate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'μR/hr', child: Text('μR/hr')),
                  DropdownMenuItem(value: 'mR/hr', child: Text('mR/hr')),
                  DropdownMenuItem(value: 'R/hr', child: Text('R/hr')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedUnit = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<DoseType>(
                      title: const Text('Gamma'),
                      value: DoseType.gamma,
                      groupValue: selectedType,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedType = value;
                          });
                        }
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<DoseType>(
                      title: const Text('Neutron'),
                      value: DoseType.neutron,
                      groupValue: selectedType,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedType = value;
                          });
                        }
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = double.tryParse(valueController.text);
                if (newValue != null) {
                  model.editDoseRate(doseRate, newValue, selectedUnit, selectedType);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid number')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCommentDialog(SurveyMapModel model, Offset pagePosition) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Comment Text',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                model.addComment(pagePosition, text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter some text')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(SurveyMapModel model, CommentAnnotation comment) {
    final textController = TextEditingController(text: comment.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Comment #${comment.id}'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Comment Text',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                model.editComment(comment, text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter some text')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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

    // Use Direct method to avoid creating undo/redo commands on every frame
    model.updateSmearPositionDirect(_draggedSmear!, newPosition);

    // Update reference to the modified smear
    final index = model.smears.indexWhere((s) => s.id == _draggedSmear!.id);
    if (index != -1) {
      _draggedSmear = model.smears[index];
    }
  }

  void _dragDoseRate(Offset focalPoint, SurveyMapModel model) {
    if (_draggedDoseRate == null || _doseRateDragOffset == null) return;

    final pagePosition = model.canvasToPage(focalPoint);
    final newPosition = pagePosition - _doseRateDragOffset!;

    // Use Direct method to avoid creating undo/redo commands on every frame
    model.updateDoseRatePositionDirect(_draggedDoseRate!, newPosition);

    // Update reference to the modified dose rate
    // Since DoseRateAnnotation doesn't have an id, we find by value and unit
    final index = model.doseRates.indexWhere(
      (d) => d.value == _draggedDoseRate!.value &&
             d.unit == _draggedDoseRate!.unit &&
             d.type == _draggedDoseRate!.type
    );
    if (index != -1) {
      _draggedDoseRate = model.doseRates[index];
    }
  }

  void _dragIcon(Offset focalPoint, SurveyMapModel model) {
    if (_draggedIcon == null || _iconDragOffset == null) {
      debugPrint('_dragIcon called but _draggedIcon or _iconDragOffset is null');
      return;
    }

    final pagePosition = model.canvasToPage(focalPoint);
    final newPosition = pagePosition - _iconDragOffset!;

    // Use Direct method to avoid creating undo/redo commands on every frame
    model.updateEquipmentPositionDirect(_draggedIcon!, newPosition);

    // Update the _draggedIcon reference to the updated equipment (which is now selectedIcon)
    _draggedIcon = model.selectedIcon;
  }

  void _dragComment(Offset focalPoint, SurveyMapModel model) {
    if (_draggedComment == null || _commentDragOffset == null) return;

    final pagePosition = model.canvasToPage(focalPoint);
    final newPosition = pagePosition - _commentDragOffset!;

    // Use Direct method to avoid creating undo/redo commands on every frame
    model.updateCommentPositionDirect(_draggedComment!, newPosition);

    // Update reference to the modified comment
    final index = model.comments.indexWhere((c) => c.id == _draggedComment!.id);
    if (index != -1) {
      _draggedComment = model.comments[index];
    }
  }

  void _dragTitleCard(Offset focalPoint, SurveyMapModel model) {
    if (!_draggedTitleCard || _titleCardDragOffset == null) return;

    final pagePosition = model.canvasToPage(focalPoint);
    final newPosition = _titleCardDragOffset!;

    // Update position directly (no undo/redo needed for title card positioning)
    model.updateTitleCardPosition(newPosition);
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
