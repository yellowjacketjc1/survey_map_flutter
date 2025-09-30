import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/survey_map_model.dart';

class ControlsPanel extends StatefulWidget {
  final VoidCallback onExport;
  final VoidCallback onReset;

  const ControlsPanel({
    super.key,
    required this.onExport,
    required this.onReset,
  });

  @override
  State<ControlsPanel> createState() => _ControlsPanelState();
}

class _ControlsPanelState extends State<ControlsPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu toggle button
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: const Icon(Icons.menu),
            label: const Text('Controls'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Controls panel
          if (_isExpanded)
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer<SurveyMapModel>(
                builder: (context, model, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Use mouse wheel to zoom and click-drag to pan.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Transform Controls',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Rotation slider
                      Row(
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text('Rotation:'),
                          ),
                          Expanded(
                            child: Slider(
                              value: model.rotation,
                              min: 0,
                              max: 360,
                              divisions: 360,
                              onChanged: (value) {
                                model.setRotation(value);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${model.rotation.toInt()}°',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Scale slider
                      Row(
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text('Scale:'),
                          ),
                          Expanded(
                            child: Slider(
                              value: model.scale,
                              min: 0.1,
                              max: 5.0,
                              divisions: 98,
                              onChanged: (value) {
                                model.setScale(value);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${(model.scale * 100).toInt()}%',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Control buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.onReset,
                              child: const Text('Reset View'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.onExport,
                              child: const Text('Export PNG'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
