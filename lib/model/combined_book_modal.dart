import 'package:carlink/model/bookrange_modal.dart';

class CombinedBookRangeModal {
  final BookRangeModal bookRangeModal;
  final BookRangeModal unavailableRangeModal;

  CombinedBookRangeModal({
    required this.bookRangeModal,
    required this.unavailableRangeModal,
  });
}
