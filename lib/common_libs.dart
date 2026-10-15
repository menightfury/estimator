import 'dart:math';

import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

// ~ Extensions
export 'common/extensions/buildcontext_extension.dart';
export 'common/extensions/color_extension.dart';
export 'common/extensions/datetime_extension.dart';
export 'common/extensions/icon_extension.dart';
export 'common/extensions/iterable_extension.dart';
export 'common/extensions/map_extension.dart';
export 'common/extensions/num_extension.dart';
export 'common/extensions/string_extension.dart';
export 'common/extensions/widget_extension.dart';

// ~ Utilities
export 'common/utils/debouncer.dart';
export 'common/utils/keyboard.dart';

export 'constants.dart';

// ~ Packages
export 'package:collection/collection.dart';
export 'package:equatable/equatable.dart';
export 'package:file_picker/file_picker.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:hydrated_bloc/hydrated_bloc.dart';
export 'package:sqflite/sqflite.dart';
export 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
export 'package:gap/gap.dart';

const $uuid = Uuid();
final $logger = Logger();
final $random = Random();
