import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/page_wrapper/page_wrapper.dart';
import 'package:IceyPlayer/helpers/common.dart';
import 'package:IceyPlayer/helpers/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LogsDetailPage extends StatelessWidget {
  const LogsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>;

    final error = extra["error"] as Report?;

    final theme = Theme.of(context);

    return PageWrapper(
      title: "错误详情",
      body: error != null
          ? Column(
              children: [
                ListItem(title: error.error, desc: error.dateTime.toString()),
                ListCard(
                  action: IconButton(
                    onPressed: () => CommonHelper.copyText(error.error),
                    icon: Icon(Icons.copy),
                  ),
                  title: "错误详情",
                  children: [
                    Text(
                      error.error.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                ListCard(
                  action: IconButton(
                    onPressed: () => CommonHelper.copyText(error.stackTrace),
                    icon: Icon(Icons.copy),
                  ),
                  title: "堆栈跟踪",
                  children: [
                    Text(
                      error.stackTrace,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            )
          : SizedBox(),
    );
  }
}
