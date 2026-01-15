import 'dart:async';

import 'package:IceyPlayer/components/button/button.dart';
import 'package:IceyPlayer/components/media_order_tile/media_order_tile.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/entities/media_order.dart';
import 'package:IceyPlayer/event_bus/event_bus.dart';
import 'package:IceyPlayer/pages/media_library/media_order/media_order_create.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

final _likedBox = Boxes.likedBox, _mediaOrderBox = Boxes.mediaOrderBox;

class MediaOrderState {
  final Signal<List<MediaOrderEntity>> mediaOrder = signal([]);
}

class MediaOrder extends StatefulWidget {
  final bool offstage;

  const MediaOrder({super.key, required this.offstage});

  @override
  State<MediaOrder> createState() => _MediaOrderState();
}

class _MediaOrderState extends State<MediaOrder> {
  final state = MediaOrderState();

  late final StreamSubscription<LikeMediaChange> _likeMediaChangeListener;

  late final StreamSubscription<MediaOrderChange> _mediaOrderChangeListener;

  late final StreamSubscription<MediaOrderCoverChange>
  _mediaOrderCoverChangeListener;

  void handleDeleteMediaOrder(
    BuildContext context,
    MediaOrderEntity mediaOrder,
  ) {
    if (mediaOrder.id == '0') return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("是否确认删除歌单"),
        content: const Text("歌单内的歌曲不会被删除"),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text("取消"),
          ),
          Button(
            child: const Text("确认"),
            onPressed: () async {
              _mediaOrderBox.delete(mediaOrder.id);

              final _mediaOrder = List<MediaOrderEntity>.from(
                state.mediaOrder.value,
              );

              final index = _mediaOrder.indexWhere(
                (e) => e.id == mediaOrder.id,
              );

              if (index != -1) {
                _mediaOrder.removeAt(index);
                state.mediaOrder.value = List.unmodifiable(_mediaOrder);
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void initLikeOrder({bool needInitMediaOrder = true}) {
    final hasLikedOrder = state.mediaOrder.value.indexWhere((e) => e.id == '0');

    if (_likedBox.values.isNotEmpty && hasLikedOrder == -1) {
      final List<int> mediaIDs = _likedBox.keys.toList().cast<int>();

      final mediaOrder = List.from(state.mediaOrder.value);

      mediaOrder.insert(
        0,
        MediaOrderEntity(id: '0', name: "我喜欢", mediaIDs: mediaIDs),
      );

      state.mediaOrder.value = List.unmodifiable(mediaOrder);
    }

    if (needInitMediaOrder != false) {
      initMediaOrder();
    }
  }

  void initMediaOrder() {
    final List<MediaOrderEntity> _mediaOrder = _mediaOrderBox.values
        .toList()
        .cast<MediaOrderEntity>();

    final mediaOrder = List.from(state.mediaOrder.value);

    mediaOrder.addAll(_mediaOrder);

    state.mediaOrder.value = List.unmodifiable(mediaOrder);
  }

  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      initLikeOrder();

      _likeMediaChangeListener = eventBus.on<LikeMediaChange>().listen((e) {
        if (_likedBox.values.isEmpty) {
          final mediaOrder = List<MediaOrderEntity>.from(
            state.mediaOrder.value,
          );

          mediaOrder.removeWhere((e) => e.id == '0');

          state.mediaOrder.value = List.unmodifiable(mediaOrder);
        } else {
          initLikeOrder(needInitMediaOrder: false);
        }
      });

      _mediaOrderChangeListener = eventBus.on<MediaOrderChange>().listen((e) {
        final mediaOrder = List<MediaOrderEntity>.from(state.mediaOrder.value);

        if (e.isDelete) {
          final index = mediaOrder.indexWhere((order) => order.id == e.id);

          if (index != -1) {
            mediaOrder.removeAt(index);

            state.mediaOrder.value = List.unmodifiable(mediaOrder);
          }
        } else {
          final index = mediaOrder.indexWhere((order) => order.id == e.id);

          if (index == -1) {
            mediaOrder.add(
              MediaOrderEntity(
                id: e.id,
                name: e.name,
                mediaIDs: [],
                cover: e.cover,
              ),
            );

            state.mediaOrder.value = List.unmodifiable(mediaOrder);
          }
        }
      });

      _mediaOrderCoverChangeListener = eventBus
          .on<MediaOrderCoverChange>()
          .listen((e) {
            final index = state.mediaOrder.value.indexWhere(
              (mediaOrder) => mediaOrder.id == e.id,
            );

            if (index != -1) {
              final mediaOrder = List<MediaOrderEntity>.from(
                state.mediaOrder.value,
              );

              mediaOrder[index] = mediaOrder[index].copyWith(cover: e.cover);

              state.mediaOrder.value = List.unmodifiable(mediaOrder);
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
    _mediaOrderChangeListener.cancel();
    _mediaOrderCoverChangeListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offstage) {
      return SizedBox.shrink();
    }

    final mediaOrder = state.mediaOrder.watch(context);

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          width: 88,
          height: 88,
          child: MediaQuery.removePadding(
            removeLeft: true,
            context: context,
            child: SuperListView.separated(
              separatorBuilder: (context, index) => SizedBox(width: 12),
              itemCount: mediaOrder.length + 1,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index < mediaOrder.length) {
                  final _mediaOrder = mediaOrder[index];

                  return MediaOrderTile(
                    key: ValueKey(_mediaOrder.id),
                    mediaOrder: _mediaOrder,
                    onLongPress: () =>
                        handleDeleteMediaOrder(context, _mediaOrder),
                  );
                }

                return MediaOrderCreate();
              },
            ),
          ),
        ),
      ),
    );
  }
}
