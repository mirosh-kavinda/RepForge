import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercise_images.g.dart';

// The catalog's pinned source (tool/seed/source/SOURCE.md), so picture URLs
// match the seed and never move.
const _sourceCommit = 'f00c92c7dcf1216a928a52c3706c7ce8e2f71ed5';

// EXL-02 AC6: [path] as stored in the catalog, e.g. "3_4_Sit-Up/0.jpg".
Uri exerciseImageUrl(String path) => Uri.https(
  'raw.githubusercontent.com',
  '/yuhonas/free-exercise-db/$_sourceCommit/exercises/$path',
);

// Kept on disk after the first load (AC6); tests override it.
@Riverpod(keepAlive: true)
ImageProvider Function(String path) exerciseImage(Ref ref) =>
    (path) => CachedNetworkImageProvider(exerciseImageUrl(path).toString());
