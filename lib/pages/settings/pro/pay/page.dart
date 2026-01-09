import 'package:IceyPlayer/components/button/button.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/helpers/toast/toast.dart';
import 'package:IceyPlayer/models/pro/pro.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class PayPage extends StatelessWidget {
  const PayPage({super.key});

  Future<void> saveImage(String path, BuildContext context) async {
    final ByteData data = await rootBundle.load(path);

    showDialog(
      builder: (context) => AlertDialog(
        title: const Text("是否保存到图库"),
        content: const Text("保存后可以到对应App扫码"),
        actions: [
          TextButton(onPressed: () {}, child: const Text("取消")),
          Button(
            child: const Text("保存"),
            onPressed: () async {
              final result = await ImageGallerySaverPlus.saveImage(
                Uint8List.fromList(Uint8List.sublistView(data)),
                quality: 100,
                name: "收款码",
              );

              if (result != null) {
                showToast("保存成功");
                context.pop();
              }
            },
          ),
        ],
      ),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: '激活Icey Pro',
      body: Column(
        spacing: 16.h,
        children: [
          ListCard(
            spacing: 8.h,
            title: '付款码(长按保存到图库)',
            padding: EdgeInsets.zero,
            children: [
              GestureDetector(
                onLongPress: () => saveImage("assets/images/zfb.jpg", context),
                child: ExtendedImage.asset("assets/images/zfb.jpg"),
              ),
              GestureDetector(
                onLongPress: () => saveImage("assets/images/wx.png", context),
                child: ExtendedImage.asset("assets/images/wx.png"),
              ),
            ],
          ),
          Button(
            block: true,
            child: const Text("我已诚信付款~"),
            onPressed: () {
              proManager.setEnabled(true);

              context.pop();
            },
          ),
          const Text(
            "即使没有付款也没事!没有人监控你的!你的下载就是最大的支持!一起进步!",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
