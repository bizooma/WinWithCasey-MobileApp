import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String youtubeUrl;
  final String? title;

  const VideoPlayerScreen({super.key, required this.youtubeUrl, this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final YoutubePlayerController _controller;
  late final String _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = _parseYoutubeId(widget.youtubeUrl);
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        strictRelatedVideos: true,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'Video';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Keep 16:9 aspect ratio for the player
              final width = constraints.maxWidth;
              final height = width * 9 / 16;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width,
                    height: height,
                    child: YoutubePlayer(controller: _controller),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_fill, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _parseYoutubeId(String url) {
    // Handles typical formats like:
    // https://www.youtube.com/watch?v=VIDEO_ID
    // https://youtu.be/VIDEO_ID
    // https://www.youtube.com/embed/VIDEO_ID
    try {
      final uri = Uri.parse(url);
      // If standard watch URL with v parameter
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;

      // youtu.be short link => path segment 1 is id
      if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }

      // embed url
      if (uri.path.contains('/embed/') && uri.pathSegments.isNotEmpty) {
        final idx = uri.pathSegments.indexOf('embed');
        if (idx != -1 && idx + 1 < uri.pathSegments.length) {
          return uri.pathSegments[idx + 1];
        }
      }
    } catch (_) {
      // ignore and fall through
    }
    return url; // fallback: assume passed id
  }
}
