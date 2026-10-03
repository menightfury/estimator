import 'dart:math';

// import 'package:faker/faker.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

export 'common/extensions/buildcontext_extension.dart';
export 'common/extensions/datetime_extension.dart';
export 'common/extensions/icon_extension.dart';
export 'common/extensions/map_extension.dart';
export 'common/extensions/num_extension.dart';
export 'common/extensions/string_extension.dart';
// export 'common/presentations/widgets/checkbox.dart';
// export 'common/presentations/widgets/choice_chips.dart';
// export 'common/presentations/widgets/column_builder.dart';
// export 'common/presentations/widgets/divider.dart';
// export 'common/presentations/widgets/selection_indicator.dart';
// export 'common/presentations/widgets/tab_indicator.dart';
// export 'common/presentations/widgets/tappable.dart';
// export 'common/presentations/widgets/currency_view.dart';
// export 'common/presentations/widgets/formatted_date.dart';
// export 'common/presentations/widgets/date_picker.dart';
// export 'common/presentations/widgets/empty_widget.dart';
// export 'common/presentations/widgets/error_widget.dart';
// export 'common/presentations/widgets/month_picker.dart';
// export 'common/presentations/widgets/section.dart';
// export 'common/presentations/widgets/circle_avatar.dart';

export 'constants.dart';

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
// final $faker = Faker();
final $random = Random();
