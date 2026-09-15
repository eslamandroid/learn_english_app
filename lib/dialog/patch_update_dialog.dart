import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/extensions.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';


Future<void> checkAndShowPatchDialog(BuildContext context) async {
  final updater = ShorebirdUpdater();

  try {
    final status = await updater.checkForUpdate();

    if (status == UpdateStatus.outdated && context.mounted) {
      await showPatchUpdateDialog(context);
    }
  } catch (e) {
    debugPrint('Shorebird check failed: $e');
  }
}

Future<void> showPatchUpdateDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _PatchUpdateDialog(),
  );
}

class _PatchUpdateDialog extends StatefulWidget {
  const _PatchUpdateDialog();

  @override
  State<_PatchUpdateDialog> createState() => _PatchUpdateDialogState();
}

class _PatchUpdateDialogState extends State<_PatchUpdateDialog> {
  final _updater = ShorebirdUpdater();

  _DialogPhase _phase = _DialogPhase.prompt;
  String? _errorMessage;

  Future<void> _startDownload() async {
    setState(() {
      _phase = _DialogPhase.downloading;
      _errorMessage = null;
    });

    try {
      await _updater.update();

      if (!mounted) return;

      setState(() {
        _phase = _DialogPhase.readyToRestart;
      });
    } on UpdateException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _DialogPhase.prompt;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _DialogPhase.prompt;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        content: switch (_phase) {
          _DialogPhase.prompt => _PromptContent(
            errorMessage: _errorMessage,
            onInstall: _startDownload,
            onLater: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
          _DialogPhase.downloading => _StatusContent(
            label: context.localization.patchDownloading,
          ),
          _DialogPhase.readyToRestart => const _ReadyToRestartContent(),
        },
      ),
    );
  }
}

enum _DialogPhase {
  prompt,
  downloading,
  readyToRestart,
}

class _PromptContent extends StatelessWidget {
  const _PromptContent({
    required this.onInstall,
    required this.onLater,
    this.errorMessage,
  });

  final VoidCallback onInstall;
  final VoidCallback onLater;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.system_update_alt_rounded, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.localization.patchAvailableTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          context.localization.patchAvailableMessage,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onInstall,
                child: Text(context.localization.patchInstallNow),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: onLater,
                child: Text(context.localization.patchLater),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusContent extends StatelessWidget {
  const _StatusContent({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyToRestartContent extends StatelessWidget {
  const _ReadyToRestartContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 52,
          color: Colors.green,
        ),
        const SizedBox(height: 14),
        Text(
          context.localization.patchDownloadedSuccess,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.localization.patchCloseAndReopen,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        // const SizedBox(height: 20),
        // SizedBox(
        //   width: double.infinity,
        //   child: ElevatedButton(
        //     onPressed: () async {
        //       await SystemNavigator.pop();
        //     },
        //     child: const Text('Close app'),
        //   ),
        // ),
      ],
    );
  }
}