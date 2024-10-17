import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum DownloadStatus {
  notDownloaded,
  fetchingDownload,
  downloading,
  downloaded,
}

@immutable
class FutureIconButton extends StatelessWidget {
  const FutureIconButton({
    super.key,
    required this.status,
    this.downloadProgress = 0.0,
    required this.onDownload,
    this.onCancel,
    this.onOpen,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.icon = Icons.save_alt,
    this.tooltip,
  });

  final DownloadStatus status;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback? onCancel;
  final VoidCallback? onOpen;
  final Duration transitionDuration;
  final IconData icon;
  final String? tooltip;

  bool get _isDownloading => status == DownloadStatus.downloading;

  bool get _isFetching => status == DownloadStatus.fetchingDownload;

  bool get _isDownloaded => status == DownloadStatus.downloaded;

  void _onPressed() {
    switch (status) {
      case DownloadStatus.notDownloaded:
        onDownload();
      case DownloadStatus.fetchingDownload:
        // do nothing.
        break;
      case DownloadStatus.downloading:
        onCancel?.call();
      case DownloadStatus.downloaded:
        onOpen?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            duration: transitionDuration,
            opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
            curve: Curves.ease,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ProgressIndicatorWidget(
                  downloadProgress: downloadProgress,
                  isDownloading: _isDownloading,
                  isFetching: _isFetching,
                ),
                if (_isDownloading)
                  const Icon(
                    Icons.stop,
                    size: 14,
                    color: CupertinoColors.activeBlue,
                  ),
              ],
            ),
          ),
        ),
        ButtonShapeWidget(
          transitionDuration: transitionDuration,
          isDownloaded: _isDownloaded,
          isDownloading: _isDownloading,
          isFetching: _isFetching,
          onPressed: _onPressed,
          icon: icon,
          tooltip: tooltip,
        ),
      ],
    );
  }
}

@immutable
class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget({
    super.key,
    required this.isDownloading,
    required this.isDownloaded,
    required this.isFetching,
    required this.transitionDuration,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  final bool isDownloading;
  final bool isDownloaded;
  final bool isFetching;
  final Duration transitionDuration;
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (isDownloading || isFetching) {}
    return AnimatedOpacity(
      duration: transitionDuration,
      opacity: isDownloading || isFetching ? 0.0 : 1.0,
      curve: Curves.ease,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
      ),
    );
  }
}

@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.downloadProgress,
    required this.isDownloading,
    required this.isFetching,
  });

  final double downloadProgress;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CircularProgressIndicator(
        backgroundColor: isDownloading
            ? CupertinoColors.lightBackgroundGray
            : Colors.white.withOpacity(0),
        valueColor: AlwaysStoppedAnimation(isFetching
            ? CupertinoColors.lightBackgroundGray
            : CupertinoColors.activeBlue),
        strokeWidth: 2,
      ),
    );
  }
}
