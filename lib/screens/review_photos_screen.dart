import 'dart:io';

import 'package:flutter/material.dart';

class ReviewPhotosScreen extends StatefulWidget {
  final List<String> initialPhotos;

  const ReviewPhotosScreen({super.key, required this.initialPhotos});

  @override
  State<ReviewPhotosScreen> createState() => _ReviewPhotosScreenState();
}

class _ReviewPhotosScreenState extends State<ReviewPhotosScreen> {
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photos = List<String>.from(widget.initialPhotos);
  }

  void _removeAt(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _photos.removeAt(oldIndex);
      _photos.insert(newIndex, item);
    });
  }

  void _finish() {
    Navigator.of(context).pop<List<String>>(_photos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Photos'),
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _photos.isEmpty
          ? const Center(child: Text('No photos to review'))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ReorderableListView.builder(
                itemCount: _photos.length,
                onReorder: _onReorder,
                proxyDecorator: (child, index, animation) => Material(
                  color: Colors.transparent,
                  child: child,
                ),
                itemBuilder: (context, index) {
                  final path = _photos[index];
                  return Card(
                    key: ValueKey(path),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () => _removeAt(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
