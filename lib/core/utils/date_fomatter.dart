import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<String> formatTaskDate(DateTime date) async {
  await initializeDateFormatting('vi_VN', null);
  return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
}

// Synchronous version as fallback
String formatTaskDateSync(DateTime date) {
  try {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
  } catch (e) {
    // Fallback to default locale if Vietnamese locale is not available
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
