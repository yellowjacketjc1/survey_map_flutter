import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/annotation_models.dart';
import '../models/posting_model.dart';

class IconLoader {
  static List<IconMetadata> loadMaterialIcons() {
    final icons = <IconMetadata>[];

    // Comprehensive list of Material Icons useful for various purposes
    final iconMap = {
      // Warning & Safety
      'warning': {'icon': Icons.warning, 'tags': ['warning', 'alert', 'caution']},
      'dangerous': {'icon': Icons.dangerous, 'tags': ['danger', 'hazard', 'warning']},
      'warning_amber': {'icon': Icons.warning_amber, 'tags': ['warning', 'amber', 'caution']},
      'error': {'icon': Icons.error, 'tags': ['error', 'problem', 'issue']},
      'report_problem': {'icon': Icons.report_problem, 'tags': ['report', 'problem', 'warning']},

      // Science & Lab
      'science': {'icon': Icons.science, 'tags': ['science', 'lab', 'equipment']},
      'biotech': {'icon': Icons.biotech, 'tags': ['biotech', 'biology', 'science']},
      'science_outlined': {'icon': Icons.science_outlined, 'tags': ['science', 'lab', 'outline']},

      // Measurement & Sensors
      'thermostat': {'icon': Icons.thermostat, 'tags': ['temperature', 'sensor']},
      'speed': {'icon': Icons.speed, 'tags': ['meter', 'gauge', 'measurement']},
      'timeline': {'icon': Icons.timeline, 'tags': ['timeline', 'graph', 'data']},
      'show_chart': {'icon': Icons.show_chart, 'tags': ['chart', 'graph', 'data']},

      // Locations & Markers
      'location_on': {'icon': Icons.location_on, 'tags': ['location', 'marker', 'pin']},
      'place': {'icon': Icons.place, 'tags': ['place', 'location', 'marker']},
      'pin_drop': {'icon': Icons.pin_drop, 'tags': ['pin', 'drop', 'location']},
      'push_pin': {'icon': Icons.push_pin, 'tags': ['push', 'pin', 'marker']},
      'room': {'icon': Icons.room, 'tags': ['room', 'location', 'place']},
      'map': {'icon': Icons.map, 'tags': ['map', 'navigation', 'location']},

      // People & Workers
      'person': {'icon': Icons.person, 'tags': ['person', 'worker', 'human']},
      'groups': {'icon': Icons.groups, 'tags': ['people', 'group', 'workers']},
      'people': {'icon': Icons.people, 'tags': ['people', 'group', 'users']},
      'engineering': {'icon': Icons.engineering, 'tags': ['engineering', 'worker', 'construction']},

      // Construction & Tools
      'construction': {'icon': Icons.construction, 'tags': ['construction', 'work', 'tools']},
      'build': {'icon': Icons.build, 'tags': ['build', 'tools', 'wrench']},
      'handyman': {'icon': Icons.handyman, 'tags': ['handyman', 'tools', 'repair']},
      'hardware': {'icon': Icons.hardware, 'tags': ['hardware', 'tools', 'equipment']},

      // Actions
      'delete': {'icon': Icons.delete, 'tags': ['delete', 'trash', 'remove']},
      'block': {'icon': Icons.block, 'tags': ['block', 'forbidden', 'restricted']},
      'cancel': {'icon': Icons.cancel, 'tags': ['cancel', 'close', 'stop']},
      'check_circle': {'icon': Icons.check_circle, 'tags': ['check', 'approved', 'ok']},
      'do_not_disturb': {'icon': Icons.do_not_disturb, 'tags': ['do not disturb', 'no', 'stop']},
      'not_interested': {'icon': Icons.not_interested, 'tags': ['not interested', 'no', 'forbidden']},

      // Information
      'info': {'icon': Icons.info, 'tags': ['info', 'information', 'help']},
      'help': {'icon': Icons.help, 'tags': ['help', 'question', 'support']},
      'report': {'icon': Icons.report, 'tags': ['report', 'document', 'flag']},

      // Media & Documentation
      'camera': {'icon': Icons.camera_alt, 'tags': ['camera', 'photo', 'picture']},
      'note': {'icon': Icons.note, 'tags': ['note', 'document', 'text']},
      'description': {'icon': Icons.description, 'tags': ['description', 'document', 'file']},
      'assignment': {'icon': Icons.assignment, 'tags': ['assignment', 'task', 'document']},

      // Time & Date
      'calendar': {'icon': Icons.calendar_today, 'tags': ['calendar', 'date', 'schedule']},
      'access_time': {'icon': Icons.access_time, 'tags': ['time', 'clock', 'schedule']},
      'schedule': {'icon': Icons.schedule, 'tags': ['schedule', 'time', 'clock']},
      'timer': {'icon': Icons.timer, 'tags': ['timer', 'time', 'stopwatch']},

      // Arrows & Directions
      'arrow_forward': {'icon': Icons.arrow_forward, 'tags': ['arrow', 'forward', 'next']},
      'arrow_back': {'icon': Icons.arrow_back, 'tags': ['arrow', 'back', 'previous']},
      'arrow_upward': {'icon': Icons.arrow_upward, 'tags': ['arrow', 'up', 'upward']},
      'arrow_downward': {'icon': Icons.arrow_downward, 'tags': ['arrow', 'down', 'downward']},
      'north': {'icon': Icons.north, 'tags': ['north', 'up', 'arrow']},
      'south': {'icon': Icons.south, 'tags': ['south', 'down', 'arrow']},
      'east': {'icon': Icons.east, 'tags': ['east', 'right', 'arrow']},
      'west': {'icon': Icons.west, 'tags': ['west', 'left', 'arrow']},
      'navigation': {'icon': Icons.navigation, 'tags': ['navigation', 'direction', 'compass']},

      // Environment
      'water_drop': {'icon': Icons.water_drop, 'tags': ['water', 'liquid', 'drop']},
      'local_fire_department': {'icon': Icons.local_fire_department, 'tags': ['fire', 'emergency']},
      'cloud': {'icon': Icons.cloud, 'tags': ['cloud', 'weather', 'atmosphere']},
      'waves': {'icon': Icons.waves, 'tags': ['waves', 'water', 'radiation']},
      'bolt': {'icon': Icons.bolt, 'tags': ['bolt', 'lightning', 'electric']},
      'power': {'icon': Icons.power, 'tags': ['power', 'energy', 'electric']},

      // Shapes & Symbols
      'circle': {'icon': Icons.circle, 'tags': ['circle', 'shape', 'round']},
      'square': {'icon': Icons.square, 'tags': ['square', 'shape', 'box']},
      'star': {'icon': Icons.star, 'tags': ['star', 'favorite', 'important']},
      'flag': {'icon': Icons.flag, 'tags': ['flag', 'marker', 'report']},
      'label': {'icon': Icons.label, 'tags': ['label', 'tag', 'category']},

      // Equipment & Objects
      'local_hospital': {'icon': Icons.local_hospital, 'tags': ['hospital', 'medical', 'health']},
      'masks': {'icon': Icons.masks, 'tags': ['mask', 'ppe', 'protection']},
      'security': {'icon': Icons.security, 'tags': ['security', 'shield', 'protection']},
      'lock': {'icon': Icons.lock, 'tags': ['lock', 'secure', 'restricted']},
      'visibility': {'icon': Icons.visibility, 'tags': ['visibility', 'eye', 'view']},
      'visibility_off': {'icon': Icons.visibility_off, 'tags': ['visibility off', 'hidden', 'eye']},
    };

    for (final entry in iconMap.entries) {
      final iconData = entry.value['icon'] as IconData;
      final tags = entry.value['tags'] as List<String>;

      icons.add(IconMetadata(
        file: 'material_${entry.key}.icon',
        name: _formatIconName(entry.key),
        category: IconCategory.equipment,
        keywords: ['material', 'icon', ...tags],
        metadata: {'iconData': iconData, 'type': 'material'},
      ));
    }

    return icons;
  }

  static String _formatIconName(String iconKey) {
    return iconKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static Future<List<IconMetadata>> loadPostingsFromJson() async {
    final icons = <IconMetadata>[];

    try {
      // Load the postings.json file
      print('Loading postings.json...');
      final jsonString = await rootBundle.loadString('assets/postings.json');
      print('JSON loaded, length: ${jsonString.length}');
      print('First 100 chars: ${jsonString.substring(0, 100)}');

      final jsonData = json.decode(jsonString);
      final postingsList = jsonData['postings'] as List<dynamic>;
      print('Found ${postingsList.length} postings');

      // Convert each posting to IconMetadata
      for (final postingJson in postingsList) {
        final posting = PostingMetadata.fromJson(postingJson);

        icons.add(IconMetadata(
          file: posting.svgFilename,
          name: '${posting.id} - ${posting.header}',
          category: IconCategory.posting,
          keywords: posting.tags.toList(),
          assetPath: posting.svgAssetPath,
          metadata: posting,
        ));
      }

      print('Successfully loaded ${icons.length} posting icons');
    } catch (e, stackTrace) {
      print('Error loading postings.json: $e');
      print('Stack trace: $stackTrace');
    }

    return icons;
  }

  static List<IconMetadata> loadEmbeddedIcons() {
    // No embedded icons - all icons loaded from postings.json
    return [];
  }
}
