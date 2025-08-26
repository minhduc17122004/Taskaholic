import 'repeat_type.dart';
import 'repeat_type_mapper.dart';

final List<RepeatType> repeatOptions = RepeatType.values;

final List<String> repeatOptionTexts = repeatOptions.map(repeatTypeToString).toList();
