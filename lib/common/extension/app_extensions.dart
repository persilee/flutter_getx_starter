/// 扩展功能库：集中引入 Flutter 依赖，并组合各个 `part` 扩展实现。
library;

import 'dart:async';
import 'dart:collection';
import 'dart:developer' as devtools show log;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'animated/animated_icon.dart';
part 'animated/animated_text.dart';
part 'animated/animated_widget.dart';
part 'colors_ext.dart';
part 'context_ext.dart';
part 'dev_tools_ext.dart';
part 'duration_ext.dart';
part 'icon_ext.dart';
part 'list_ext.dart';
part 'media_query_ext.dart';
part 'padding_ext.dart';
part 'platform_ext.dart';
part 'screen/screen_util.dart';
part 'screen/_flutter_widgets.dart';
part 'screen/screenutil_init.dart';
part 'screen/screenutil_mixin.dart';
part 'screen_util_ext.dart';
part 'sized_box_ext.dart';
part 'string_ext.dart';
part 'text_ext.dart';
part 'text_span_ext.dart';
part 'themes_ext.dart';
part 'widget_ext.dart';
