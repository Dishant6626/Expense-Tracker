// lib/core/services/gemini_service.dart

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';

import '../../config/env/environment.dart';
import '../../core/constants/app_constants.dart';
import '../../features/expense/models/expense_model.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  String get _apiKey => Environment().config.geminiApiKey;
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-2.0-flash';

  // ── Receipt scanning ────────────────────────────────────────────────────────

  Future<ExtractedReceiptData> scanReceipt(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final extension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

      const prompt = '''
Analyze this receipt image and extract the following information. 
Return ONLY a valid JSON object with these exact keys (no markdown, no backticks):
{
  "merchant_name": "name of the store/restaurant/merchant or null",
  "date": "date in YYYY-MM-DD format or null",
  "amount": total amount as a number (float) or null,
  "category": one of exactly: Food, Shopping, Travel, Utilities, Entertainment, Others
}

If you cannot extract any field, use null for that field.
If this is not a receipt, set all fields to null and add "error": "Not a receipt".
''';

      final response = await _dio.post(
        '$_baseUrl/$_model:generateContent?key=$_apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': base64Image,
                  }
                },
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 500,
          }
        },
      );

      final text = response.data['candidates'][0]['content']['parts'][0]['text']
      as String;

      return _parseReceiptResponse(text);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      log("message::${e.response}");
      if (statusCode == 429) {
        return ExtractedReceiptData.invalid('Rate limit exceeded. Try again later.');
      } else if (statusCode == 400) {
        return ExtractedReceiptData.invalid('Invalid image format.');
      }
      return ExtractedReceiptData.invalid('Network error: ${e.message}');
    } catch (e) {
      return ExtractedReceiptData.invalid('Failed to process receipt: $e');
    }
  }

  ExtractedReceiptData _parseReceiptResponse(String rawText) {
    try {
      // Strip any markdown code fences
      String clean = rawText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final json = jsonDecode(clean) as Map<String, dynamic>;

      if (json.containsKey('error')) {
        return ExtractedReceiptData.invalid(json['error'] as String);
      }

      DateTime? parsedDate;
      if (json['date'] != null) {
        try {
          parsedDate = DateTime.parse(json['date'] as String);
        } catch (_) {
          parsedDate = null;
        }
      }

      double? parsedAmount;
      if (json['amount'] != null) {
        parsedAmount = (json['amount'] as num?)?.toDouble();
      }

      ExpenseCategory? parsedCategory;
      if (json['category'] != null) {
        parsedCategory = ExpenseCategory.fromString(json['category'] as String);
      }

      final hasMinimalData = parsedAmount != null || json['merchant_name'] != null;

      return ExtractedReceiptData(
        merchantName: json['merchant_name'] as String?,
        date: parsedDate,
        amount: parsedAmount,
        category: parsedCategory,
        rawResponse: rawText,
        isValid: hasMinimalData,
        errorMessage: hasMinimalData ? null : 'Could not extract data from this image.',
      );
    } catch (e) {
      return ExtractedReceiptData.invalid('Failed to parse AI response.');
    }
  }

  // ── Spending insights ───────────────────────────────────────────────────────

  Future<String> generateSpendingInsights(List<ExpenseModel> expenses) async {
    if (expenses.isEmpty) {
      return 'No expenses found. Start adding expenses to get AI-powered insights!';
    }

    try {
      final expenseSummary = _buildExpenseSummary(expenses);

      final prompt = '''
You are a personal finance assistant. Analyze the following expense data and provide a helpful, 
friendly spending report in plain text (no markdown headers, no bullet asterisks).

Expense Data:
$expenseSummary

Write a 4-6 sentence spending analysis that includes:
1. Total spending amount
2. The biggest spending category
3. Any notable spending pattern or trend
4. At least one specific, actionable recommendation to save money

Keep it conversational, encouraging, and under 150 words.
Example tone: "You spent ₹12,450 this month. Food was your biggest expense at 35%..."
''';

      final response = await _dio.post(
        '$_baseUrl/$_model:generateContent?key=$_apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 300,
          }
        },
      );

      final text = response.data['candidates'][0]['content']['parts'][0]['text']
          as String;
      return text.trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return 'Rate limit reached. Please try again in a moment.';
      }
      return 'Unable to generate insights right now. Please check your connection.';
    } catch (e) {
      return 'Something went wrong generating insights. Please try again.';
    }
  }

  String _buildExpenseSummary(List<ExpenseModel> expenses) {
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final byCategory = <String, double>{};

    for (final e in expenses) {
      byCategory[e.category.label] =
          (byCategory[e.category.label] ?? 0) + e.amount;
    }

    final sorted = expenses.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top3 = sorted.take(3).map((e) => '${e.title}: ₹${e.amount.toStringAsFixed(0)}').join(', ');

    final now = DateTime.now();
    final thisMonth = expenses.where((e) =>
        e.date.month == now.month && e.date.year == now.year);
    final lastMonth = expenses.where((e) =>
        e.date.month == now.month - 1 && e.date.year == now.year);

    return '''
Total expenses (all time): ₹${total.toStringAsFixed(2)}
Number of transactions: ${expenses.length}
This month total: ₹${thisMonth.fold<double>(0, (s, e) => s + e.amount).toStringAsFixed(2)} (${thisMonth.length} transactions)
Last month total: ₹${lastMonth.fold<double>(0, (s, e) => s + e.amount).toStringAsFixed(2)} (${lastMonth.length} transactions)
Category breakdown: ${byCategory.entries.map((e) => '${e.key}: ₹${e.value.toStringAsFixed(0)}').join(', ')}
Largest expenses: $top3
''';
  }
}
