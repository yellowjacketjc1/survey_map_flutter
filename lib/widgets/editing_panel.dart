import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/survey_map_model.dart';
import '../models/annotation_models.dart';
import 'icon_library.dart';

class EditingPanel extends StatelessWidget {
  const EditingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.edit, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Editing Tools',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Consumer<SurveyMapModel>(
              builder: (context, model, child) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSmearSection(context, model),
                    const SizedBox(height: 16),
                    _buildDoseRateSection(context, model),
                    const SizedBox(height: 16),
                    _buildBoundarySection(context, model),
                    const SizedBox(height: 16),
                    _buildEquipmentSection(context, model),
                    const SizedBox(height: 16),
                    _buildClearAllSection(context, model),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmearSection(BuildContext context, SurveyMapModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Removable Smears',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_circle, size: 20),
              color: model.currentTool == ToolType.smearAdd
                  ? Colors.blue
                  : Colors.grey,
              tooltip: 'Add Smear',
              onPressed: () => model.setTool(ToolType.smearAdd),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, size: 20),
              color: model.currentTool == ToolType.smearRemove
                  ? Colors.blue
                  : Colors.grey,
              tooltip: 'Remove Smear',
              onPressed: () => model.setTool(ToolType.smearRemove),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Text('Next ID:'),
              const SizedBox(width: 8),
              Text(
                '${model.nextSmearId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoseRateSection(BuildContext context, SurveyMapModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Dose Rates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_circle, size: 20),
              color: model.currentTool == ToolType.doseAdd
                  ? Colors.blue
                  : Colors.grey,
              tooltip: 'Add Dose Rate',
              onPressed: () => model.setTool(ToolType.doseAdd),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, size: 20),
              color: model.currentTool == ToolType.doseRemove
                  ? Colors.blue
                  : Colors.grey,
              tooltip: 'Remove Dose Rate',
              onPressed: () => model.setTool(ToolType.doseRemove),
            ),
          ],
        ),
        if (model.currentTool == ToolType.doseAdd) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) {
                            model.setDoseValue(parsed);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: model.doseUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'μR/hr', child: Text('μR/hr')),
                          DropdownMenuItem(
                              value: 'mR/hr', child: Text('mR/hr')),
                          DropdownMenuItem(value: 'R/hr', child: Text('R/hr')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            model.setDoseUnit(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<DoseType>(
                        title: const Text('Gamma'),
                        value: DoseType.gamma,
                        groupValue: model.doseType,
                        onChanged: (value) {
                          if (value != null) {
                            model.setDoseType(value);
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
                        groupValue: model.doseType,
                        onChanged: (value) {
                          if (value != null) {
                            model.setDoseType(value);
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
          ),
        ],
      ],
    );
  }

  Widget _buildBoundarySection(BuildContext context, SurveyMapModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Boundaries',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.crop_square, size: 20),
              color: model.currentTool == ToolType.boundary
                  ? Colors.blue
                  : Colors.grey,
              tooltip: 'Draw Boundary',
              onPressed: () => model.setTool(ToolType.boundary),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, size: 20),
              color: model.currentTool == ToolType.boundaryDelete
                  ? Colors.blue
                  : Colors.grey,
              tooltip: 'Delete Boundary',
              onPressed: () => model.setTool(ToolType.boundaryDelete),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(BuildContext context, SurveyMapModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Icon Library',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.open_in_full, size: 20),
              color: Colors.blue,
              tooltip: 'Open Icon Browser',
              onPressed: () => _showIconBrowserDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: model.currentTool == ToolType.equipmentDelete
                  ? Colors.red
                  : Colors.grey,
              tooltip: 'Delete Equipment',
              onPressed: () => model.setTool(ToolType.equipmentDelete),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const IconLibrary(),
      ],
    );
  }

  void _showIconBrowserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 900,
          height: 700,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Icon Browser',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Expanded(
                  child: IconLibrary(isExpanded: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearAllSection(BuildContext context, SurveyMapModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clear All',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Annotations'),
                  content: const Text(
                      'Are you sure you want to clear all annotations? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        model.clearAllAnnotations();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Annotations'),
          ),
        ),
      ],
    );
  }
}
