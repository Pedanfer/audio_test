import '../imports.dart';

class HomePage extends StatefulWidget {
  final HomePageProvider provider;

  const HomePage({super.key, required this.provider});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Test"),
      ),
      body: FutureBuilder<void>(
        future: widget.provider.init(),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (details) {
                    try {
                      widget.provider.setSpeed(details);
                    } on Exception catch (error) {
                      print(error);
                    }
                  },
                  child: SizedBox.expand(
                    child: Center(
                      child: widget.provider.hasAudio
                          ? AudioPlayerWidget(
                              audioPlayer: widget.provider.audioPlayer)
                          : _contentNoFiles(),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(strokeWidth: 3),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _infoFileSnackBar(context);
          await widget.provider.onPressedPickAudioFile();
          setState(() {});
        },
        tooltip: 'Escoge una canción',
        child: const Icon(
          FontAwesomeIcons.solidFileAudio,
          size: 32,
        ),
      ),
    );
  }

  Column _contentNoFiles() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.music,
                size: 30,
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 4),
              Transform.translate(
                offset: const Offset(0, 2),
                child: const Icon(
                  FontAwesomeIcons.music,
                  size: 20,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          FontAwesomeIcons.boxOpen,
          size: 80,
          color: Colors.blueGrey,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text("No hay audios, ¡escoge alguno!"),
        )
      ],
    );
  }
}

void _infoFileSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(
            FontAwesomeIcons.circleInfo,
            color: Colors.yellow,
          ),
          Text("Sólo podrá escoger ficheros de audio.")
        ],
      ),
    ),
  );
}
