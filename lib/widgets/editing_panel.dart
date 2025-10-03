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
                    _buildTitleCardSection(context, model),
                    const SizedBox(height: 16),
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

  Widget _buildTitleCardSection(BuildContext context, SurveyMapModel model) {
    final titleCard = model.titleCard;
    if (titleCard == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Title Card',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                titleCard.visible ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              color: titleCard.visible ? Colors.blue : Colors.grey,
              tooltip: titleCard.visible ? 'Hide Title Card' : 'Show Title Card',
              onPressed: () => model.toggleTitleCardVisibility(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Survey ID #',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                controller: TextEditingController(text: titleCard.surveyId)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: titleCard.surveyId.length),
                  ),
                onChanged: (value) => model.updateTitleCardField(surveyId: value),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Surveyor Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                controller: TextEditingController(text: titleCard.surveyorName)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: titleCard.surveyorName.length),
                  ),
                onChanged: (value) => model.updateTitleCardField(surveyorName: value),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: titleCard.date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    model.updateTitleCardField(date: date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(
                    '${titleCard.date.month}/${titleCard.date.day}/${titleCard.date.year}',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Building #',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      controller: TextEditingController(text: titleCard.buildingNumber)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: titleCard.buildingNumber.length),
                        ),
                      onChanged: (value) => model.updateTitleCardField(buildingNumber: value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Room #',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      controller: TextEditingController(text: titleCard.roomNumber)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: titleCard.roomNumber.length),
                        ),
                      onChanged: (value) => model.updateTitleCardField(roomNumber: value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${model.nextSmearId}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
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
              icon: const Icon(Icons.add_circle, size: 20),
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
