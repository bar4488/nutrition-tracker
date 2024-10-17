import 'package:app_platform/app_platform.dart';
import 'package:flutter/widgets.dart';
import 'package:nutrition_routine/persistence.dart';
import 'package:nutrition_routine/widgets/save_button.dart';

class SaveController with ChangeNotifier {
  SaveController(
      {DownloadStatus downloadStatus = DownloadStatus.notDownloaded,
      double progress = 0.0,
      required this.state})
      : _downloadStatus = downloadStatus,
        _progress = progress;

  DownloadStatus _downloadStatus;
  @override
  DownloadStatus get downloadStatus => _downloadStatus;

  Model state;
  double _progress;
  @override
  double get progress => _progress;

  void save() {
    _doSimulatedDownload();
  }

  Future<void> _doSimulatedDownload() async {
    _downloadStatus = DownloadStatus.downloading;
    notifyListeners();

    await saveState(state.serialize());

    notifyListeners();
    _downloadStatus = DownloadStatus.notDownloaded;
    notifyListeners();
  }
}

class LoadController with ChangeNotifier {
  LoadController(
      {DownloadStatus downloadStatus = DownloadStatus.notDownloaded,
      double progress = 0.0,
      required this.state})
      : _downloadStatus = downloadStatus,
        _progress = progress;

  DownloadStatus _downloadStatus;
  @override
  DownloadStatus get downloadStatus => _downloadStatus;

  Model state;
  double _progress;
  @override
  double get progress => _progress;

  void load() {
    _loadState();
  }

  Future<void> _loadState() async {
    _downloadStatus = DownloadStatus.downloading;
    notifyListeners();

    state.update(await loadState());

    notifyListeners();
    _downloadStatus = DownloadStatus.notDownloaded;
    notifyListeners();
  }
}
