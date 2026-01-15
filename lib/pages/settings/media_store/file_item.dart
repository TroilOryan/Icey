import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

class FileItem extends StatelessWidget {
  final String path;
  final bool? isFiltered;
  final VoidCallback onPressed;

  const FileItem(
      {super.key,
      required this.path,
      this.isFiltered = false,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
        dense: true,
        contentPadding: EdgeInsets.only(left: 8),
        leading: SFIcon(SFIcons.sf_folder_fill,
            color: isFiltered == true
                ? theme.textTheme.bodyMedium?.color
                : theme.colorScheme.primary),
        title: Text(path,
            style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 12,
                color: isFiltered == true
                    ? theme.textTheme.bodyMedium?.color
                    : theme.textTheme.titleMedium?.color)),
        trailing: IconButton(
            onPressed: onPressed,
            icon: SFIcon(
              isFiltered == true
                  ? SFIcons.sf_eye_fill
                  : SFIcons.sf_eye_slash_fill,
              fontSize: 12,
            )));
  }
}
