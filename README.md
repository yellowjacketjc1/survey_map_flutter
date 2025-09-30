# SurveyMap - Flutter/Dart Version

A complete Flutter conversion of the SurveyMap radiological survey mapping tool.

## Features

- **PDF Loading**: Load PDF floor plans and maps
- **Pan, Zoom, Rotate**: Interactive transformation controls
- **Removable Smears**: Add numbered smear locations with drag-and-drop
- **Dose Rates**: Add gamma and neutron dose rate measurements
- **Boundaries**: Draw custom boundaries with click-to-add points
- **Equipment Library**: Drag-and-drop equipment icons and radiological posting signs
- **Icon Management**: Search and filter icons by category
- **Export**: Export annotated maps as PNG images

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:
```bash
flutter run
```

For web:
```bash
flutter run -d chrome
```

For desktop (macOS):
```bash
flutter run -d macos
```

## Project Structure

```
lib/
├── main.dart                      # Application entry point
├── models/
│   ├── annotation_models.dart     # Data models for annotations
│   └── survey_map_model.dart      # Main state management
├── screens/
│   └── home_screen.dart           # Main screen with upload/workspace
├── services/
│   ├── pdf_service.dart           # PDF loading and rendering
│   ├── icon_loader.dart           # Icon library loading
│   └── export_service.dart        # PNG export functionality
└── widgets/
    ├── map_canvas.dart            # Interactive canvas with gestures
    ├── map_painter.dart           # Custom painter for rendering
    ├── controls_panel.dart        # Transform controls UI
    ├── editing_panel.dart         # Tool panel UI
    └── icon_library.dart          # Icon library UI
```

## Usage

### Loading a PDF

1. Click "Choose File" on the upload screen
2. Select a PDF file from your device
3. The first page will be rendered on the canvas

### Adding Annotations

**Smears:**
- Click the `+` button next to "Removable Smears"
- Click on the map to place numbered smears
- Drag smears to reposition them
- Click the `-` button to remove smears

**Dose Rates:**
- Click the `+` button next to "Dose Rates"
- Enter value and select unit
- Choose Gamma or Neutron
- Click on the map to place dose rate

**Boundaries:**
- Click the boundary button (⬜)
- Left-click to add points
- Right-click to undo last point
- Double-click to finish boundary

**Equipment Icons:**
- Search or filter icons in the Equipment Library
- Click an icon to place it at the center (or use drag in future update)
- Select and drag icons to reposition
- Use corner handles to resize

### Controls

- **Mouse Wheel**: Zoom in/out
- **Click + Drag**: Pan the map
- **Sliders**: Adjust rotation and scale
- **Reset View**: Return to default view
- **Export PNG**: Save the annotated map

## Key Differences from JavaScript Version

1. **State Management**: Uses Provider pattern instead of class-based state
2. **Rendering**: Custom painters instead of HTML Canvas
3. **PDF Loading**: Uses `pdf_render` package instead of PDF.js
4. **File Picking**: Uses `file_picker` package for cross-platform support
5. **SVG Rendering**: Uses `flutter_svg` package with image caching
6. **Gestures**: Native Flutter gesture detection instead of DOM events

## Dependencies

- `pdf_render`: PDF rendering
- `file_picker`: Cross-platform file selection
- `flutter_svg`: SVG icon rendering
- `provider`: State management
- `image`: Image manipulation
- `path_provider`: File system access

## Platform Support

- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux
- ⚠️ iOS (limited file picker support)
- ⚠️ Android (limited file picker support)

## Known Limitations

1. Icon drag-and-drop from library to canvas not yet implemented (icons place at center)
2. Mobile gesture support could be improved
3. No undo/redo functionality yet
4. Export quality could be enhanced with custom rendering

## Future Enhancements

- [ ] Drag icons directly from library to canvas
- [ ] Undo/redo support
- [ ] Save/load projects
- [ ] Multiple page PDF support
- [ ] Custom annotation styles
- [ ] Print support
- [ ] Cloud storage integration

## Development

### Adding New Icons

Icons are loaded in `lib/services/icon_loader.dart`. To add new icons:

1. Add SVG string to the `loadEmbeddedIcons()` method
2. Include appropriate metadata (name, category, keywords)

### Modifying Annotations

Annotation models are in `lib/models/annotation_models.dart`. To add new annotation types:

1. Create a new model class
2. Add to `SurveyMapModel`
3. Update `MapPainter` to render it
4. Add UI controls in `EditingPanel`

## License

Same as original SurveyMap project.

## Credits

Flutter conversion of the original JavaScript/HTML SurveyMap application.
