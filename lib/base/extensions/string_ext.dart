import 'dart:convert';

import 'package:learn_english_app/base/extensions/num_ext.dart';
import 'package:learn_english_app/base/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

extension StringNullableExt on String? {
  String get toSafeString => (this != null && this!.isNotEmpty) ? this! : '';
}

extension StringExt on String {
  String get toSafeString => (isNotEmpty) ? this : '';

  TextDirection get toTextDirection =>
      intl.Bidi.detectRtlDirectionality(this)
          ? TextDirection.rtl
          : TextDirection.ltr;

  String get toFormatPrice =>
      num.tryParse(
        this,
      )?.let((it) => intl.NumberFormat('#,##0.00', 'en_US').format(it)) ??
      this;

  String get toPrice =>
      num.tryParse(
        this,
      )?.let((it) => intl.NumberFormat('#,##0', 'en_US').format(it)) ??
      this;

  Color get toColor {
    final buffer = StringBuffer();
    if (length == 6 || length == 7) buffer.write('ff');
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String get toDisplayDate => intl.DateFormat(
    "yyy-MM-dd",
  ).format(intl.DateFormat("yyy-MM-dd").parse(this));

  String get toDisplayDateWithTime => intl.DateFormat(
    "d MMM yyy, HH:mm:ss",
  ).format(intl.DateFormat("yyy-MM-dd HH:mm:ss").parse(this));

  String get toDisplayNameDate => intl.DateFormat(
    "d MMM yyy",
  ).format(intl.DateFormat("yyy-MM-dd HH:mm:ss").parse(this));

  String get toFirstUpper => "${this[0].toUpperCase()}${substring(1, length)}";

  String timeAgo({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(DateTime.parse(this));
    if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }

  String get encodeToBase64 {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(toString());
    return encoded;
  }

  bool get isValidEmail {
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return isNotEmpty && regex.hasMatch(this);
  }

  bool get validateMobileNumber {
    String pattern = r'^(?:[+0][1-9])?[0-9]{7,12}$';
    RegExp regExp = RegExp(pattern);
    return isNotEmpty && regExp.hasMatch(this);
  }

  String get decode64ToString {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String decoded = stringToBase64.decode(this);
    return decoded;
  }

  String get uniCodeDecoding {
    return utf8.decode(codeUnits);
  }

  int toInt() => int.parse(this);

  String emojiCountry() {
    final int firstLetter = codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  Map<String, String> originalPhone({bool exact = false}) {
    const middleEastCodes = {
      "966": "SA",
      "971": "AE",
      "973": "BH",
      "965": "KW",
      "968": "OM",
      "974": "QA",
      "20": "EG",
      "962": "JO",
      "961": "LB",
      "963": "SY",
      "964": "IQ",
      "970": "PS",
      "90": "TR",
      "98": "IR",
      "967": "YE",
      "972": "IL",
      "211": "SS",
      "249": "SD",
      "212": "MA",
      "213": "DZ",
      "216": "TN",
      "218": "LY",
    };

    final cleaned = replaceAll(RegExp(r'\D'), '');

    final matchedCode =
        middleEastCodes.keys.toList()
          ..sort((a, b) => b.length.compareTo(a.length));

    for (final code in matchedCode) {
      if (cleaned.startsWith(code)) {
        final local = cleaned.substring(code.length);
        return {
          "phone": this,
          "countryCode": middleEastCodes[code] ?? "Unknown",
          "dial": code,
          "localNumber": local,
        };
      }
    }

    return {
      "phone": this,
      "countryCode": "Unknown",
      "dial": "",
      "localNumber": cleaned,
    };
  }

  double? tryParseWithFixedPrecision() {
    if (this == 'null') return null;
    return double.tryParse(this)?.toPrecision(2);
  }

  String get toEnglishNumber {
    String input = this;
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < arabicDigits.length; i++) {
      input = input.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return input;
  }

  String ifEmpty(String value) {
    return isEmpty? value : this;
  }
}
