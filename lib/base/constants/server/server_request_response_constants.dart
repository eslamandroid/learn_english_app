class ServerRequestResponseConstants {
  const ServerRequestResponseConstants._();

  static const basicAuthorization = "Authorization";
  static const userAgentKey = "User-Agent";
  static const bearer = "Bearer";
  static const contentType = "Content-Type";
  static const applicationJson = "application/json";
  static const basic = "Basic";
  static const store = "store";
  static const isCookieExist = "is-cookie-exist";
  static const cookie = "Cookie";
  static const localHeader = "x-locale";
  static const currencyHeader = "x-currency";
    static const cacheControlHeader = "Cache-control";

  static const sessionTimeMilli = 50 * 60000;

  // currency
  static const sarCurrency = "SAR";


  // language code
  static const en = "EN";
  static const ar = "AR";

  // gender
  static const male = 0;
  static const female = 1;
  static const other = 2;
  static const unknown = -1;

}
