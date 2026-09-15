import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../data/task.dart';
import '../providers/task_provider.dart';

enum NoteMode { write, draw }

const _palette = [
  Colors.black,
  Colors.red,
  Colors.orange,
  Colors.green,
  Colors.blue,
  Colors.purple,
];

class _Stroke {
  _Stroke(this.color, this.width) : points = [];
  final Color color;
  final double width;
  final List<Offset> points;
}

/// One screen for both note formats: rich text and a hand-drawn sketch.
/// A segmented control switches modes; each mode's tools live behind their
/// own collapsible bar(s) instead of a toolbar that eats the whole screen.
class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key, required this.task, this.initialMode = NoteMode.write});
  final Task task;
  final NoteMode initialMode;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late NoteMode _mode = widget.initialMode;
  late final QuillController _quillController = _controllerFor(widget.task.richNotes);

  final _boundaryKey = GlobalKey();
  final List<_Stroke> _strokes = [];
  Color _penColor = _palette.first;
  double _penWidth = 4;
  bool _showBackground = true;

  static QuillController _controllerFor(String? richNotes) {
    if (richNotes == null) return QuillController.basic();
    try {
      final delta = jsonDecode(richNotes) as List;
      return QuillController(document: Document.fromJson(delta), selection: const TextSelection.collapsed(offset: 0));
    } catch (_) {
      return QuillController.basic();
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
        actions: [
          IconButton(icon: const Icon(Icons.check), tooltip: 'Save', onPressed: _save),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<NoteMode>(
              segments: const [
                ButtonSegment(value: NoteMode.write, icon: Icon(Icons.text_fields), label: Text('Write')),
                ButtonSegment(value: NoteMode.draw, icon: Icon(Icons.brush_outlined), label: Text('Draw')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _mode == NoteMode.write ? 0 : 1,
              children: [_buildWriteMode(), _buildDrawMode()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteMode() {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _CollapsibleBar(
                  title: 'Style',
                  child: QuillSimpleToolbar(
                    controller: _quillController,
                    config: const QuillSimpleToolbarConfig(
                      showFontFamily: true,
                      showFontSize: true,
                      showBoldButton: true,
                      showItalicButton: true,
                      showUnderLineButton: true,
                      showStrikeThrough: true,
                      showColorButton: true,
                      showBackgroundColorButton: true,
                      showClearFormat: true,
                      showInlineCode: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showSmallButton: false,
                      showHeaderStyle: false,
                      showListNumbers: false,
                      showListBullets: false,
                      showListCheck: false,
                      showCodeBlock: false,
                      showQuote: false,
                      showIndent: false,
                      showLink: false,
                      showUndo: false,
                      showRedo: false,
                      showSearchButton: false,
                      showDividers: false,
                    ),
                  ),
                ),
                _CollapsibleBar(
                  title: 'Structure',
                  child: QuillSimpleToolbar(
                    controller: _quillController,
                    config: const QuillSimpleToolbarConfig(
                      showFontFamily: false,
                      showFontSize: false,
                      showBoldButton: false,
                      showItalicButton: false,
                      showUnderLineButton: false,
                      showStrikeThrough: false,
                      showColorButton: false,
                      showBackgroundColorButton: false,
                      showClearFormat: false,
                      showInlineCode: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showHeaderStyle: true,
                      showListNumbers: true,
                      showListBullets: true,
                      showListCheck: true,
                      showCodeBlock: true,
                      showQuote: true,
                      showIndent: true,
                      showLink: false,
                      showUndo: false,
                      showRedo: false,
                      showSearchButton: false,
                      showDividers: false,
                    ),
                  ),
                ),
                _CollapsibleBar(
                  title: 'Insert & undo',
                  initiallyExpanded: false,
                  child: QuillSimpleToolbar(
                    controller: _quillController,
                    config: const QuillSimpleToolbarConfig(
                      showFontFamily: false,
                      showFontSize: false,
                      showBoldButton: false,
                      showItalicButton: false,
                      showUnderLineButton: false,
                      showStrikeThrough: false,
                      showColorButton: false,
                      showBackgroundColorButton: false,
                      showClearFormat: false,
                      showHeaderStyle: false,
                      showListNumbers: false,
                      showListBullets: false,
                      showListCheck: false,
                      showCodeBlock: false,
                      showQuote: false,
                      showIndent: false,
                      showLink: true,
                      showUndo: true,
                      showRedo: true,
                      showSearchButton: true,
                      showDividers: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: QuillEditor.basic(controller: _quillController),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawMode() {
    final hasBackground = _showBackground && widget.task.drawingPath != null;

    return Column(
      children: [
        _CollapsibleBar(
          title: 'Pen',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (final c in _palette) _ColorDot(c, selected: c == _penColor, onTap: () => setState(() => _penColor = c)),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _penWidth,
                    min: 1,
                    max: 16,
                    onChanged: (v) => setState(() => _penWidth = v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.layers_clear_outlined),
                  tooltip: 'Clear',
                  onPressed: () => setState(() {
                    _strokes.clear();
                    _showBackground = false;
                  }),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: RepaintBoundary(
            key: _boundaryKey,
            child: GestureDetector(
              onPanStart: (d) => setState(() => _strokes.add(_Stroke(_penColor, _penWidth)..points.add(d.localPosition))),
              onPanUpdate: (d) => setState(() => _strokes.last.points.add(d.localPosition)),
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasBackground) Image.file(File(widget.task.drawingPath!), fit: BoxFit.cover),
                    CustomPaint(painter: _DrawingPainter(_strokes)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    // IndexedStack keeps both modes built even when not visible, so only
    // persist a mode if it actually has content (or already existed) —
    // otherwise every note would pick up a blank drawing/empty rich text.
    final hasDrawing = _strokes.isNotEmpty || widget.task.drawingPath != null;
    final hasRichText = _quillController.document.toPlainText().trim().isNotEmpty || widget.task.richNotes != null;

    String? drawingPath = widget.task.drawingPath;
    if (hasDrawing) {
      final boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/drawing_${widget.task.id}.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());
      drawingPath = file.path;
    }
    if (!mounted) return;
    final provider = context.read<TaskProvider>();
    if (hasDrawing) provider.setDrawing(widget.task.id, drawingPath);
    if (hasRichText) {
      provider.setRichNotes(widget.task.id, jsonEncode(_quillController.document.toDelta().toJson()));
    }
    Navigator.of(context).pop();
  }
}

/// A titled bar with an arrow that expands/collapses its content —
/// keeps the always-visible chrome to one line per group.
class _CollapsibleBar extends StatelessWidget {
  const _CollapsibleBar({required this.title, required this.child, this.initiallyExpanded = true});
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      initiallyExpanded: initiallyExpanded,
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: EdgeInsets.zero,
      shape: const Border(),
      children: [child],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot(this.color, {required this.selected, required this.onTap});
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) : null,
          ),
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter(this.strokes);
  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
