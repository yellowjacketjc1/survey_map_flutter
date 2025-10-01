import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/annotation_models.dart';
import '../models/posting_model.dart';

class IconLoader {
  static List<IconMetadata> loadMaterialIcons() {
    final icons = <IconMetadata>[];

    // Get ALL Material Icons via reflection-like approach
    // We'll use a comprehensive curated list of commonly used Material Icons
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

      // Additional commonly used icons
      'add': {'icon': Icons.add, 'tags': ['add', 'plus', 'new']},
      'remove': {'icon': Icons.remove, 'tags': ['remove', 'minus', 'subtract']},
      'edit': {'icon': Icons.edit, 'tags': ['edit', 'modify', 'change']},
      'save': {'icon': Icons.save, 'tags': ['save', 'store', 'disk']},
      'close': {'icon': Icons.close, 'tags': ['close', 'cancel', 'exit']},
      'check': {'icon': Icons.check, 'tags': ['check', 'ok', 'confirm']},
      'done': {'icon': Icons.done, 'tags': ['done', 'complete', 'finished']},
      'settings': {'icon': Icons.settings, 'tags': ['settings', 'config', 'gear']},
      'home': {'icon': Icons.home, 'tags': ['home', 'house', 'main']},
      'search': {'icon': Icons.search, 'tags': ['search', 'find', 'magnify']},
      'filter': {'icon': Icons.filter_list, 'tags': ['filter', 'sort', 'list']},
      'menu': {'icon': Icons.menu, 'tags': ['menu', 'hamburger', 'list']},
      'more_vert': {'icon': Icons.more_vert, 'tags': ['more', 'vertical', 'options']},
      'more_horiz': {'icon': Icons.more_horiz, 'tags': ['more', 'horizontal', 'options']},
      'refresh': {'icon': Icons.refresh, 'tags': ['refresh', 'reload', 'update']},
      'sync': {'icon': Icons.sync, 'tags': ['sync', 'synchronize', 'update']},
      'download': {'icon': Icons.download, 'tags': ['download', 'save', 'get']},
      'upload': {'icon': Icons.upload, 'tags': ['upload', 'send', 'put']},
      'share': {'icon': Icons.share, 'tags': ['share', 'send', 'export']},
      'print': {'icon': Icons.print, 'tags': ['print', 'printer', 'output']},
      'email': {'icon': Icons.email, 'tags': ['email', 'mail', 'message']},
      'phone': {'icon': Icons.phone, 'tags': ['phone', 'call', 'telephone']},
      'chat': {'icon': Icons.chat, 'tags': ['chat', 'message', 'talk']},
      'notifications': {'icon': Icons.notifications, 'tags': ['notification', 'alert', 'bell']},
      'folder': {'icon': Icons.folder, 'tags': ['folder', 'directory', 'files']},
      'file': {'icon': Icons.insert_drive_file, 'tags': ['file', 'document', 'page']},
      'image': {'icon': Icons.image, 'tags': ['image', 'picture', 'photo']},
      'attach_file': {'icon': Icons.attach_file, 'tags': ['attach', 'file', 'clip']},
      'link': {'icon': Icons.link, 'tags': ['link', 'url', 'chain']},
      'bookmark': {'icon': Icons.bookmark, 'tags': ['bookmark', 'save', 'favorite']},
      'favorite': {'icon': Icons.favorite, 'tags': ['favorite', 'heart', 'like']},
      'thumb_up': {'icon': Icons.thumb_up, 'tags': ['thumbs up', 'like', 'approve']},
      'thumb_down': {'icon': Icons.thumb_down, 'tags': ['thumbs down', 'dislike', 'reject']},
      'verified': {'icon': Icons.verified, 'tags': ['verified', 'check', 'approved']},
      'new_releases': {'icon': Icons.new_releases, 'tags': ['new', 'release', 'star']},
      'trending_up': {'icon': Icons.trending_up, 'tags': ['trending', 'up', 'increase']},
      'trending_down': {'icon': Icons.trending_down, 'tags': ['trending', 'down', 'decrease']},
      'account_circle': {'icon': Icons.account_circle, 'tags': ['account', 'user', 'profile']},
      'account_box': {'icon': Icons.account_box, 'tags': ['account', 'user', 'box']},
      'exit_to_app': {'icon': Icons.exit_to_app, 'tags': ['exit', 'logout', 'leave']},
      'vpn_key': {'icon': Icons.vpn_key, 'tags': ['key', 'password', 'access']},
      'brightness_high': {'icon': Icons.brightness_high, 'tags': ['brightness', 'light', 'sun']},
      'brightness_low': {'icon': Icons.brightness_low, 'tags': ['brightness', 'dark', 'dim']},
      'battery_full': {'icon': Icons.battery_full, 'tags': ['battery', 'full', 'power']},
      'wifi': {'icon': Icons.wifi, 'tags': ['wifi', 'wireless', 'network']},
      'bluetooth': {'icon': Icons.bluetooth, 'tags': ['bluetooth', 'wireless', 'device']},
      'gps_fixed': {'icon': Icons.gps_fixed, 'tags': ['gps', 'location', 'fixed']},
      'my_location': {'icon': Icons.my_location, 'tags': ['location', 'my', 'gps']},
      'layers': {'icon': Icons.layers, 'tags': ['layers', 'stack', 'levels']},
      'palette': {'icon': Icons.palette, 'tags': ['palette', 'color', 'paint']},
      'straighten': {'icon': Icons.straighten, 'tags': ['ruler', 'measure', 'straighten']},
      'category': {'icon': Icons.category, 'tags': ['category', 'group', 'organize']},
      'dashboard': {'icon': Icons.dashboard, 'tags': ['dashboard', 'overview', 'panel']},
      'view_list': {'icon': Icons.view_list, 'tags': ['list', 'view', 'items']},
      'view_module': {'icon': Icons.view_module, 'tags': ['grid', 'view', 'module']},
      'view_quilt': {'icon': Icons.view_quilt, 'tags': ['quilt', 'view', 'layout']},
      'fullscreen': {'icon': Icons.fullscreen, 'tags': ['fullscreen', 'expand', 'maximize']},
      'fullscreen_exit': {'icon': Icons.fullscreen_exit, 'tags': ['fullscreen exit', 'minimize', 'restore']},
      'zoom_in': {'icon': Icons.zoom_in, 'tags': ['zoom', 'in', 'magnify']},
      'zoom_out': {'icon': Icons.zoom_out, 'tags': ['zoom', 'out', 'reduce']},
      'crop': {'icon': Icons.crop, 'tags': ['crop', 'cut', 'trim']},
      'rotate_left': {'icon': Icons.rotate_left, 'tags': ['rotate', 'left', 'turn']},
      'rotate_right': {'icon': Icons.rotate_right, 'tags': ['rotate', 'right', 'turn']},
      'flip': {'icon': Icons.flip, 'tags': ['flip', 'mirror', 'reverse']},
      'straighten_outlined': {'icon': Icons.straighten_outlined, 'tags': ['straighten', 'ruler', 'measure']},
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
