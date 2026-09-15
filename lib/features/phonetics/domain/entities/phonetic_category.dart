import 'package:equatable/equatable.dart';

class PhoneticCategory extends Equatable {
  final int id;
  final String title;
  final String titleAr;
  final String icon;
  final int articleCount;

  const PhoneticCategory({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.icon,
    required this.articleCount,
  });

  @override
  List<Object?> get props => [id, title, titleAr, icon, articleCount];
}
