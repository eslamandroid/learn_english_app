import 'package:equatable/equatable.dart';

class PhoneticTableItem extends Equatable {
  final int id;
  final int sectionId;
  final int sortOrder;
  final String title;
  final String value;

  const PhoneticTableItem({
    required this.id,
    required this.sectionId,
    required this.sortOrder,
    required this.title,
    required this.value,
  });

  @override
  List<Object?> get props => [id, sectionId, sortOrder, title, value];
}
