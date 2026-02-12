import 'package:IceyPlayer/components/like_button/like_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import '../../constants/box_key.dart';

final _likedBox = Boxes.likedBox;

class PlayLikeButton extends StatefulWidget {
  final String? id;
  final double size;
  final bool? liked;
  final Color? color;
  final Future<bool?> Function(bool isLiked)? onTap;

  const PlayLikeButton({
    super.key,
    required this.id,
    this.size = 24.0,
    this.liked = false,
    this.color,
    this.onTap,
  });

  @override
  State<PlayLikeButton> createState() => _PlayLikeButtonState();
}

class _PlayLikeButtonState extends State<PlayLikeButton> {
  bool isLiked = false;

  void _initState() {
    if (widget.id == null) {
      return;
    }

    setState(() {
      isLiked = _likedBox.get(widget.id!, defaultValue: false);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initState();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.color ?? Theme.of(context).colorScheme.onSurface;

    return LikeButton(
      isLiked: isLiked,
      likeBuilder: (bool isLiked) {
        return Icon(
          isLiked ? SFIcons.sf_heart_fill : SFIcons.sf_heart,
          size: widget.size,
          color: isLiked ? Colors.red : iconColor,
        );
      },
      onTap: widget.onTap,
      size: widget.size,
    );
  }
}
