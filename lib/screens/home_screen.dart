import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/survey_map_model.dart';
import '../services/pdf_service.dart';
import '../services/icon_loader.dart';
import '../services/export_service.dart';
import '../services/pdf_export_service.dart';
import '../widgets/map_canvas.dart';
import '../widgets/controls_panel.dart';
import '../widgets/editing_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    final model = context.read<SurveyMapModel>();

    // Load all icon types
    final embeddedIcons = IconLoader.loadEmbeddedIcons();
    final postingIcons = await IconLoader.loadPostingsFromJson();
    final materialIcons = IconLoader.loadMaterialIcons();

    model.setIconLibrary([...embeddedIcons, ...postingIcons, ...materialIcons]);
  }

  Future<void> _pickAndLoadPdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pdfBytes = await PdfService.pickPdfFile();
      if (pdfBytes != null) {
        final model = context.read<SurveyMapModel>();
        model.setPdfBytes(pdfBytes);

        final image = await PdfService.loadPdfPage(pdfBytes);
        if (image != null) {
          model.setPdfImage(image);
        } else {
          _showError('Failed to load PDF page');
        }
      }
    } catch (e) {
      _showError('Error loading PDF: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportMap() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pngBytes = await ExportService.captureWidget(_canvasKey);
      if (pngBytes != null) {
        final filePath = await ExportService.savePngToFile(pngBytes);
        if (filePath != null) {
          _showSuccess('Map exported to: $filePath');
        } else {
          _showError('Failed to save PNG file');
        }
      } else {
        _showError('Failed to capture map');
      }
    } catch (e) {
      _showError('Error exporting map: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportPdf() async {
    setState(() {
      _isLoading = true;
    });

    // Give UI time to update
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final model = context.read<SurveyMapModel>();
      await PdfExportService.exportToPdf(model, _canvasKey);
      if (mounted) {
        _showSuccess('PDF exported successfully');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error exporting PDF: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _printMap() async {
    setState(() {
      _isLoading = true;
    });

    // Give UI time to update
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final model = context.read<SurveyMapModel>();
      await PdfExportService.printMap(model, _canvasKey);
    } catch (e) {
      if (mounted) {
        _showError('Error printing map: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetView() {
    final model = context.read<SurveyMapModel>();
    final size = MediaQuery.of(context).size;
    model.resetView(Size(size.width * 0.7, size.height));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _saveProject() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final model = context.read<SurveyMapModel>();
      final jsonData = model.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      // Ask user where to save
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Survey Map Project',
        fileName: 'survey_map_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsString(jsonString);
        _showSuccess('Project saved to: $outputPath');
      }
    } catch (e) {
      _showError('Error saving project: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProject() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Load Survey Map Project',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;

        final model = context.read<SurveyMapModel>();
        await model.fromJson(jsonData);

        // Reload PDF image if PDF bytes are present
        if (model.pdfBytes != null) {
          final image = await PdfService.loadPdfPage(model.pdfBytes!);
          if (image != null) {
            model.setPdfImage(image);
            _showSuccess('Project loaded successfully');
          } else {
            _showError('Project loaded but failed to render PDF');
          }
        } else {
          _showSuccess('Project loaded successfully (no PDF)');
        }
      }
    } catch (e) {
      _showError('Error loading project: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SurveyMapModel>(
        builder: (context, model, child) {
          return Stack(
            children: [
              if (!model.hasPdf) _buildUploadSection() else _buildWorkspace(),
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            const Icon(
              Icons.map,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'SurveyMap',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Radiological Survey Mapping Tool',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            // Upload area
            Container(
              width: 500,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload PDF Map',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Click the button below to select your PDF file',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _pickAndLoadPdf,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Choose File'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspace() {
    return Row(
      children: [
        // Main map area
        Expanded(
          child: Stack(
            children: [
              RepaintBoundary(
                key: _canvasKey,
                child: const MapCanvas(),
              ),
              ControlsPanel(
                onReset: _resetView,
                onSave: _saveProject,
                onLoad: _loadProject,
                onExportPdf: _exportPdf,
                onPrint: _printMap,
              ),
            ],
          ),
        ),
        // Right editing panel
        const EditingPanel(),
      ],
    );
  }
}
