import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateService {
  static const String _baseUrl = "https://open.er-api.com/v6/latest";
  static const String _cachePrefix = "exchange_rate_";
  static const int _cacheHours = 24; // rates valid for 24 hours

  // Set to true whenever the most recent convert() call had to fall back
  // to an expired/stale cached rate because no fresh rate was available.
  bool usedStaleRate = false;

  //Main converson method
  Future<double> convert(
    double amount, {
    required String from,
    required String to,
  }) async {
    usedStaleRate = false; // Reset flag for this conversion
    //If same currency, no conversion needed
    if (from == to) return amount;
    final rate = await _getRate(from: from, to: to);
    print("Exchange rate from $from to $to: $rate * $amount");
    return amount * rate;
  }

  //Get exchange rate with cache
  Future<double> _getRate({required String from, required String to}) async {
    print("🔍 Getting rate: $from → $to");

    // Try cache first
    final cachedRate = await _getCachedRate(from, to);
    if (cachedRate != null) {
      print("✅ Cache hit: $cachedRate");

      return cachedRate;
    }
    print("❌ Cache miss, fetching from API...");

    // fetch from frankfurter.app
    try {
      final url = "$_baseUrl/$from";
      print("🌐 Calling: $url");
      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: 10));
      print("📡 Status: ${response.statusCode}");
      print("📦 Body: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("💱 Rates available: ${data['rates']}");
        if (data['rates'][to] == null) {
          print("⚠️ Target currency $to not found in response");
          //return 1.0; // Fallback if target currency not found
          throw Exception("Invalid API response.");
        }

        final rates = data['rates'] as Map<String, dynamic>;

        //cache all rates at once to reduce future API calls
        for (final entry in rates.entries) {
          await _cacheRate(from, entry.key, (entry.value as num).toDouble());
        }
        final rate = (rates[to] as num).toDouble();
        print("✅ Rate found: $rate");

        return rate;
      } else {
        throw Exception("Exchange rate API returned ${response.statusCode}");
      }
    } catch (e) {
      print("💥 Error: $e");
      // No internet / API failure — fall back to an expired cached rate if one exists,
      // rather than failing completely.
      final staleRate = await _getStaleCachedRate(from, to);
      if (staleRate != null) {
        usedStaleRate = true;
        print("⚠️ Using stale cached rate: $staleRate");
        return staleRate;
      }

      // throw Exception("ExchangeRateService error: $e");
      rethrow;
    }
    // print("⚠️ Falling back to 1.0");

    //return 1.0; // Fallback to 1.0 if something goes wrong
    // throw Exception('Unable to fetch exchange rate');
  }

  // Cache rate to SharedPreferences
  Future<void> _cacheRate(String from, String to, double rate) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "$_cachePrefix${from}_$to";
    await prefs.setDouble("${key}_rate", rate);
    await prefs.setInt("${key}_time", DateTime.now().millisecondsSinceEpoch);
  }

  // Get cached rate if still valid
  Future<double?> _getCachedRate(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "$_cachePrefix${from}_$to";
    final rate = prefs.getDouble("${key}_rate");
    final timestamp = prefs.getInt("${key}_time");

    if (rate == null || timestamp == null) return null;
    //check if cache is still valid
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final isExpired =
        DateTime.now().difference(cachedTime).inHours >= _cacheHours;
    if (isExpired) {
      //clear expired cache
      // await prefs.remove("${key}_rate");
      // await prefs.remove("${key}_time");
      return null;
    }
    return rate;
  }

  Future<double?> _getStaleCachedRate(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "$_cachePrefix${from}_$to";
    final rate = prefs.getDouble("${key}_rate");
    return rate;
  }
}
