import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/models/backup/available_album.model.dart';
import 'package:immich_mobile/providers/backup/backup.provider.dart';
import 'package:immich_mobile/routing/router.dart';
import 'package:immich_mobile/providers/haptic_feedback.provider.dart';

class AlbumInfoListTile extends HookConsumerWidget {
  final AvailableAlbum album;

  const AlbumInfoListTile({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSelected =
        ref.watch(backupProvider).selectedBackupAlbums.contains(album);
    var assetCount = useState(0);

    useEffect(
      () {
        album.assetCount.then((value) => assetCount.value = value);
        return null;
      },
      [album],
    );

    buildTileColor() {
      if (isSelected) {
        return context.isDarkTheme
            ? context.primaryColor.withAlpha(100)
            : context.primaryColor.withAlpha(25);
      } else {
        return Colors.transparent;
      }
    }

    buildIcon() {
      if (isSelected) {
        return const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
        );
      }

      return Icon(
        Icons.circle,
        color: context.isDarkTheme ? Colors.grey[400] : Colors.black45,
      );
    }

    return GestureDetector(
      child: ListTile(
        tileColor: buildTileColor(),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        onTap: () {
          ref.read(hapticFeedbackProvider.notifier).selectionClick();
          if (isSelected) {
            ref.read(backupProvider.notifier).removeAlbumForBackup(album);
          } else {
            ref.read(backupProvider.notifier).addAlbumForBackup(album);
          }
        },
        leading: buildIcon(),
        title: Text(
          album.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(assetCount.value.toString()),
        trailing: IconButton(
          onPressed: () {
            context.pushRoute(
              AlbumPreviewRoute(album: album.albumEntity),
            );
          },
          icon: Icon(
            Icons.image_outlined,
            color: context.primaryColor,
            size: 24,
          ),
          splashRadius: 25,
        ),
      ),
    );
  }
}
