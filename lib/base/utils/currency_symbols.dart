const _currencySymbols = <String, String>{
  "usd": "\$",
  "euro": "€",
  "gbp": "£",
  "jpy": "¥",
  "chf": "CHF",
  "aud": "AU\$",
  "cad": "CA\$",
  "inr": "₹",
  "sar": " ر.س",
  "aed": "AD",
  "egp": "E£",
};

extension SymbolsExt on String {
  String? toSymbol() => (_currencySymbols.containsKey(toLowerCase())
      ? _currencySymbols[toLowerCase()]
      : this);

  String toSarSymbol(String lang)=> lang == "ar"?" ر.س":"SAR";
}
