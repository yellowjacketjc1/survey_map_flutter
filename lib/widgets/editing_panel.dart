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
                    _buildCommentSection(context, model),
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
    final isActive = model.currentTool == ToolType.smearAdd;

    return InkWell(
      onTap: () {
        // Toggle between smearAdd and none
        if (model.currentTool == ToolType.smearAdd) {
          model.setTool(ToolType.none);
        } else {
          model.setTool(ToolType.smearAdd);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Text(
              'Removable Smears',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${model.smears.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.blue.shade700 : Colors.black54,
                ),
              ),
            ),
            const Spacer(),
            if (isActive)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseRateSection(BuildContext context, SurveyMapModel model) {
    final isActive = model.currentTool == ToolType.doseAdd;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            // Toggle between doseAdd and none
            if (model.currentTool == ToolType.doseAdd) {
              model.setTool(ToolType.none);
            } else {
              model.setTool(ToolType.doseAdd);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
              border: Border.all(
                color: isActive ? Colors.blue : Colors.grey.shade300,
                width: isActive ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text(
                  'Dose Rates',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (model.currentTool == ToolType.doseAdd) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(width: 2),
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
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: () => model.setDoseType(DoseType.gamma),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<DoseType>(
                              value: DoseType.gamma,
                              groupValue: model.doseType,
                              onChanged: (value) {
                                if (value != null) {
                                  model.setDoseType(value);
                                }
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text('Gamma', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: InkWell(
                        onTap: () => model.setDoseType(DoseType.neutron),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<DoseType>(
                              value: DoseType.neutron,
                              groupValue: model.doseType,
                              onChanged: (value) {
                                if (value != null) {
                                  model.setDoseType(value);
                                }
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text('Neutron', style: TextStyle(fontSize: 13)),
                          ],
                        ),
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
    final isActive = model.currentTool == ToolType.boundary;

    return InkWell(
      onTap: () {
        // Toggle between boundary and none
        if (model.currentTool == ToolType.boundary) {
          model.setTool(ToolType.none);
        } else {
          model.setTool(ToolType.boundary);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Text(
              'Boundaries',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (isActive)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(BuildContext context, SurveyMapModel model) {
    final isActive = model.currentTool == ToolType.commentAdd;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            // Toggle between commentAdd and none
            if (model.currentTool == ToolType.commentAdd) {
              model.setTool(ToolType.none);
            } else {
              model.setTool(ToolType.commentAdd);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
              border: Border.all(
                color: isActive ? Colors.blue : Colors.grey.shade300,
                width: isActive ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text(
                  'Comments/Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${model.comments.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.blue.shade700 : Colors.black54,
                    ),
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (model.comments.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: model.comments.map((comment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue.shade700, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${comment.id}',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          comment.text,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
