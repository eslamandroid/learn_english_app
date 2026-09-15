import 'package:flutter/material.dart';

class PriceViewWidget extends StatelessWidget {
  final bool splitFractionFromPrice;
  final String? currency;
  final String price;
  final TextStyle? currencyStyle;
  final TextStyle? priceStyle;
  final TextStyle? priceFractionStyle;

  const PriceViewWidget(
      {super.key,
      this.splitFractionFromPrice = false,
      this.currency = "ر.س",
      required this.price,
      this.priceStyle,
      this.priceFractionStyle,
      this.currencyStyle});

  @override
  Widget build(BuildContext context) {
    List<String> parts = price.split('.');

    return Text.rich(TextSpan(children: [
      if (!splitFractionFromPrice) TextSpan(text: price, style: priceStyle),
      if (splitFractionFromPrice) ...[
        TextSpan(
          text: parts[0],
          style: priceStyle,
        ),
        if (parts.length > 1) ...[
          TextSpan(
            text: '.${parts[1]}',
            style: priceFractionStyle,
          ),
        ],
      ],
      if (currency != null) TextSpan(text: currency, style: currencyStyle),
    ]));
  }
}

