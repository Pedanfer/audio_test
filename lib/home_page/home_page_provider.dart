import 'dart:ui';
import '../imports.dart';

class HomePageProvider {
  Duration? audioDuration;
  late AudioPlayer audioPlayer;
  late SharedPreferences sharedPrefs;
  late List<double> twentyParts;
  double screenHeight = (window.physicalSize / window.devicePixelRatio).height;

  Future<void> init() async {
    sharedPrefs = await SharedPreferences.getInstance();
    await _setAudioSource();
    twentyParts = [
      for (double i = 0; i < screenHeight; i += screenHeight / 20) i
    ];
  }

  bool get hasAudio => audioDuration != null;

  Future<void> _setAudioSource() async {
    String audioUrl = sharedPrefs.getString(Constants.AUDIO_URL) ?? "";
    audioPlayer = AudioPlayer();
    if (audioUrl.isNotEmpty) {
      audioDuration =
          (await audioPlayer.setAudioSource(AudioSource.file(audioUrl)));
    }
  }

  Future<void> onPressedPickAudioFile() async {
    audioPlayer.stop();
    await Future.delayed(const Duration(seconds: 2), () async {
      final sharedPrefs = await SharedPreferences.getInstance();
      String? selectedDirectory =
          sharedPrefs.getString(Constants.AUDIO_DIRECTORY);
      if (selectedDirectory != null) {
        await _pickFile(selectedDirectory);
      } else {
        selectedDirectory = await FilePicker.platform.getDirectoryPath();
        if (selectedDirectory != null) {
          await sharedPrefs.setString(
              Constants.AUDIO_DIRECTORY, selectedDirectory);
          await _pickFile(selectedDirectory);
        }
      }
    });
  }

  Future<void> _pickFile(String selectedDirectory) async {
    final file = await FilePicker.platform.pickFiles(
        onFileLoading: ((status) {
          if (status.name == "done") {}
        }),
        type: FileType.audio,
        allowMultiple: false,
        initialDirectory: selectedDirectory);
    String? filePath = file?.files.first.path;
    if (filePath != null) {
      await sharedPrefs.setString(Constants.AUDIO_URL, filePath);
      init();
    }
  }

  setSpeed(DragUpdateDetails details) {
    double speed = 1.0;

    final dragPosition = details.globalPosition.dy;

    if (dragPosition < screenHeight / 2) {
      for (double section in twentyParts.sublist(0, 10)) {
        if (dragPosition < section) {
          speed += 0.1;
        }
      }
    } else {
      for (double section in twentyParts.sublist(10)) {
        if (dragPosition > section) {
          speed -= 0.075;
        }
      }
    }

    audioPlayer.setSpeed(speed);
  }
}
