import 'dart:typed_data';

import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/button/button.dart';
import 'package:IceyPlayer/components/icey_switch/icey_switch.dart';
import 'package:IceyPlayer/components/high_material_wrapper/high_material_wrapper.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/entities/media_order.dart';
import 'package:IceyPlayer/event_bus/event_bus.dart';
import 'package:IceyPlayer/helpers/image.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:uuid/uuid.dart';

final _mediaOrderBox = Boxes.mediaOrderBox;

const uuid = Uuid();

class MediaOrderCreate extends StatefulWidget {
  const MediaOrderCreate({super.key});

  @override
  State<MediaOrderCreate> createState() => _MediaOrderCreateState();
}

class _MediaOrderCreateState extends State<MediaOrderCreate> {
  void handleOpenCreateMediaOrder(BuildContext context) {
    final theme = Theme.of(context);
    final customizeCover = signal(false);
    final Signal<Uint8List?> customizeCoverData = signal(null);
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController();

    scrollableBottomSheet(
      context: context,
      builder: (context) {
        final _customizeCover = customizeCover.watch(context),
            _customizeCoverData = customizeCoverData.watch(context);

        return [
          Text("创建歌单", style: theme.textTheme.titleMedium),
          ListCard(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  autofocus: true,
                  controller: _textController,
                  decoration: InputDecoration(
                    fillColor: theme.cardTheme.color,
                    hint: Text(
                      "输入歌单名称",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    errorStyle: TextStyle(color: Colors.red), // 错误提示样式
                  ),
                  // 核心校验逻辑
                  validator: (value) {
                    // 去除首尾空格后检查是否为空
                    if (value?.trim().isEmpty ?? true) {
                      return "至少输入一个字符"; // 错误提示文本
                    }
                    return null; // 校验通过
                  },
                  // 可选：实时校验（输入时触发）
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              ListItem(
                title: "自定义封面",
                trailing: IceySwitch(
                  value: _customizeCover,
                  onChanged: (v) => customizeCover.value = v,
                ),
              ),
              Offstage(
                offstage: !_customizeCover,
                child: Center(
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
                    child: Ink(
                      child: InkWell(
                        onTap: () async {
                          final res = await ImageHelper().selectImage();

                          if (res != null) {
                            customizeCoverData.value = res;
                          }
                        },
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: _customizeCoverData != null
                              ? ExtendedImage.memory(
                                  _customizeCoverData,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Column(
                                    spacing: 8,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(SFIcons.sf_plus),
                                      Text("歌单封面"),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Button(
            block: true,
            child: Text("创建歌单"),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final id = uuid.v4();

                final name = _textController.text.trim();

                _mediaOrderBox.put(
                  id,
                  MediaOrderEntity(
                    id: id,
                    name: name,
                    mediaIDs: [],
                    cover: _customizeCoverData,
                  ),
                );

                eventBus.fire(
                  MediaOrderChange(
                    id: id,
                    name: name,
                    cover: _customizeCoverData,
                  ),
                );

                showToast("创建成功");

                context.pop();
              }
            },
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HighMaterialWrapper(
      borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
      builder: (highMaterial) => Material(
        color: highMaterial
            ? theme.cardTheme.color!.withAlpha(AppTheme.defaultAlphaLight)
            : theme.cardTheme.color,
        child: Ink(
          child: InkWell(
            onTap: () => handleOpenCreateMediaOrder(context),
            child: SizedBox(
              width: 88,
              height: 88,
              child: const Center(child: Icon(SFIcons.sf_plus)),
            ),
          ),
        ),
      ),
    );
  }
}
