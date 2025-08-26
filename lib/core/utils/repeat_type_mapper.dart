import 'repeat_type.dart';

RepeatType repeatTypeFromString(String value) {
  switch (value) {
    case 'Hàng ngày': return RepeatType.daily;
    case 'Hàng ngày (Thứ 2-Thứ 6)': return RepeatType.weekdays;
    case 'Hàng tuần': return RepeatType.weekly;
    case 'Hàng tháng': return RepeatType.monthly;
    case 'Hàng năm': return RepeatType.yearly;
    case 'Không lặp lại':
    default:
      return RepeatType.none;
  }
}

String repeatTypeToString(RepeatType type) {
  switch (type) {
    case RepeatType.daily: return 'Hàng ngày';
    case RepeatType.weekdays: return 'Hàng ngày (Thứ 2-Thứ 6)';
    case RepeatType.weekly: return 'Hàng tuần';
    case RepeatType.monthly: return 'Hàng tháng';
    case RepeatType.yearly: return 'Hàng năm';
    case RepeatType.none: return 'Không lặp lại';
  }
}
