import 'dart:async';
import 'dart:typed_data';

import 'package:audio_query/audio_query.dart';
import 'package:audio_query/types/artwork_type.dart';
import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/entities/media_order.dart';
import 'package:IceyPlayer/event_bus/event_bus.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

final _mediaOrderBox = Boxes.mediaOrderBox, _likedBox = Boxes.likedBox;

class MediaOrderTile extends StatefulWidget {
  final MediaOrderEntity mediaOrder;
  final VoidCallback onLongPress;

  const MediaOrderTile({
    super.key,
    required this.mediaOrder,
    required this.onLongPress,
  });

  @override
  State<MediaOrderTile> createState() => _MediaOrderTileState();
}

class _MediaOrderTileState extends State<MediaOrderTile> {
  late final Signal<Uint8List> cover = signal(
    widget.mediaOrder.cover ?? Uint8List(0),
  );

  late final StreamSubscription<LikeMediaChange> _likeMediaChangeListener;

  late final StreamSubscription<MediaOrderChange> _mediaOrderChangeListener;

  late final StreamSubscription<MediaOrderCoverChange>
  _mediaOrderCoverChangeListener;

  Future<void> handleCover() async {
    List<String> mediaIDs = [];

    if (widget.mediaOrder.id == '0') {
      mediaIDs = _likedBox.keys.toList().cast<String>();
    } else {
      if (widget.mediaOrder.cover != null) {
        cover.value = widget.mediaOrder.cover!;

        return;
      } else {
        mediaIDs = _mediaOrderBox.get(widget.mediaOrder.id).mediaIDs;
      }
    }

    if (mediaIDs.isNotEmpty) {
      final coverRes = await AudioQuery().queryArtwork(
        mediaIDs.last,
        ArtworkType.AUDIO,
        size: 512,
      );

      cover.value = coverRes ?? Uint8List(0);
    }
  }

  void handleTap(BuildContext context) {
    context.push(
      "/media_order_detail/${widget.mediaOrder.id}",
      extra: {
        "randomCover": cover.value.isNotEmpty ? cover.value : null,
        "cover": widget.mediaOrder.cover ?? Uint8List(0),
        "name": widget.mediaOrder.name,
      },
    );
  }

  Future<void> onInit() async {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      handleCover();

      _likeMediaChangeListener = eventBus.on<LikeMediaChange>().listen((e) {
        handleCover();
      });

      _mediaOrderChangeListener = eventBus.on<MediaOrderChange>().listen((e) {
        if (e.id == widget.mediaOrder.id) {
          handleCover();
        }
      });

      _mediaOrderCoverChangeListener = eventBus
          .on<MediaOrderCoverChange>()
          .listen((e) {
            if (e.id == widget.mediaOrder.id) {
              cover.value = e.randomCover ?? e.cover ?? Uint8List(0);
            }
          });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _likeMediaChangeListener.cancel();
    _mediaOrderCoverChangeListener.cancel();
    _mediaOrderChangeListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final _cover = cover.watch(context);

    return GestureDetector(
      onTap: () => handleTap(context),
      onLongPress: widget.onLongPress,
      child: SizedBox(
        width: 88,
        child: Stack(
          children: [
            Hero(
              tag: "mediaOrderDetail_${widget.mediaOrder.id}",
              child: _cover.isNotEmpty
                  ? ExtendedImage.memory(
                      _cover,
                      gaplessPlayback: true,
                      width: 88,
                      fit: BoxFit.cover,
                      clipBehavior: Clip.antiAlias,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
                    )
                  : ExtendedImage.asset(
                      'assets/images/no_cover.png',
                      fit: BoxFit.cover,
                      width: 88,
                      gaplessPlayback: true,
                      clipBehavior: Clip.antiAlias,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
                    ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: HighMaterialWrapper(
                decoration: (highMaterial) => BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  color: theme.cardTheme.color!.withAlpha(
                    highMaterial
                        ? AppTheme.defaultAlphaLight
                        : AppTheme.defaultAlpha,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                borderRadius: BorderRadius.all(Radius.circular(8)),
                builder: (_) => Text(
                  widget.mediaOrder.name,
                  style: theme.textTheme.bodyLarge!.copyWith(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
