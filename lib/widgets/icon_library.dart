import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/survey_map_model.dart';
import '../models/annotation_models.dart';

class IconLibrary extends StatelessWidget {
  const IconLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SurveyMapModel>(
      builder: (context, model, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search icons...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => model.setIconSearchQuery(value),
            ),
            const SizedBox(height: 8),
            // Category filter
            DropdownButtonFormField<IconCategory?>(
              value: model.iconCategoryFilter,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...IconCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.displayName),
                  );
                }),
              ],
              onChanged: (value) => model.setIconCategoryFilter(value),
            ),
            const SizedBox(height: 12),
            // Icon grid
            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: model.filteredIcons.isEmpty
                  ? const Center(
                      child: Text(
                        'No icons found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: model.filteredIcons.length,
                      itemBuilder: (context, index) {
                        final icon = model.filteredIcons[index];
                        return _IconCard(icon: icon);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _IconCard extends StatelessWidget {
  final IconMetadata icon;

  const _IconCard({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _onIconTap(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon preview
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: SvgPicture.string(
                    icon.svgText,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Icon info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      icon.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: icon.category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        icon.category.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: icon.category.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_circle_outline, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  void _onIconTap(BuildContext context) {
    final model = context.read<SurveyMapModel>();

    // Show a snackbar to inform user to click on canvas
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Click on the map to place "${icon.name}"'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: () {},
        ),
      ),
    );

    // For now, we'll add the equipment at center of PDF
    // In a real implementation, you'd enable a placement mode
    final centerPosition = Offset(
      model.pdfSize.width / 2,
      model.pdfSize.height / 2,
    );

    model.addEquipment(
      EquipmentAnnotation(
        position: centerPosition,
        iconFile: icon.file,
        iconSvg: icon.svgText,
        width: 80,
        height: 80,
      ),
    );
  }
}
