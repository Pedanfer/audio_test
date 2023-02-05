import 'dart:async';

import '../imports.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const AudioPlayerWidget({super.key, required this.audioPlayer});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool musicPaused = false;
  late StreamSubscription audioSubscription;

  @override
  void initState() {
    audioSubscription =
        widget.audioPlayer.positionStream.listen((Duration timeElapsed) {
      if (timeElapsed >= widget.audioPlayer.duration!) {
        widget.audioPlayer.seek(const Duration(seconds: 0));
        widget.audioPlayer.stop();
        setState(() {
          musicPaused = false;
        });
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    audioSubscription.cancel();
    widget.audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: widget.audioPlayer.positionStream,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProgressBar(
                barHeight: 30,
                progress: widget.audioPlayer.position,
                buffered: widget.audioPlayer.bufferedPosition,
                total: widget.audioPlayer.duration!,
                onSeek: (duration) {
                  widget.audioPlayer.seek(duration);
                },
              ),
              _playButton()
            ],
          ),
        );
      },
    );
  }

  Widget _playButton() {
    return GestureDetector(
      child: Icon(
        !musicPaused
            ? Icons.play_circle_fill_rounded
            : Icons.pause_circle_filled_rounded,
        size: 60,
        color: Colors.blue,
      ),
      onTap: () {
        if (!musicPaused) {
          widget.audioPlayer.play();
          musicPaused = true;
        } else {
          widget.audioPlayer.pause();
          musicPaused = false;
        }
        setState(() {});
      },
    );
  }
}
