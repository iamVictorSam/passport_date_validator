import 'package:google_ml_kit/google_ml_kit.dart';

class PassportValidator {
  static Future<bool?> recognizedText(String pickedImage) async {
    var extractedText;
    if (pickedImage == null) {
      // Get.snackbar("Error", "image is not selected",
      //     backgroundColor: ColorPalette.red);
    } else {
      extractedText = '';
      print(pickedImage);
      var textRecognizer = GoogleMlKit.vision.textRecognizer();
      final visionImage = InputImage.fromFilePath(pickedImage);
      // final recognizerText = textRecognizer.processImage(visionImage);

      // print(recognizerText);
      try {
        var visionText = await textRecognizer.processImage(visionImage);
        print(visionText);
        for (TextBlock textBlock in visionText.blocks) {
          for (TextLine textLine in textBlock.lines) {
            for (TextElement textElement in textLine.elements) {
              extractedText = extractedText + textElement.text;
            }
          }
        }

        // print('extractedText: $extractedText');
        var next35 =
            extractCharAfterLastExp(extractedText.toString().toLowerCase());
        var country =
            extractCountryName(extractedText.toString().toLowerCase());
        // print(next35);
        // print(country);
        return parseDateByCountry(next35, country);
      } catch (e) {
        // Get.snackbar("Error", e.toString(), backgroundColor: ColorPalette.red);
        // throw 'err';
        print('err: $e');
      }
    }
    return null;
  }

  static String extractCharAfterLastExp(String input) {
    List<String> wordsAndSentences = input.split(' ');

    String result = '';
    int lastExpIndex = -1;

    for (int i = 0; i < wordsAndSentences.length; i++) {
      String wordOrSentence = wordsAndSentences[i];

      if (wordOrSentence.contains('exp')) {
        lastExpIndex = wordOrSentence.lastIndexOf('exp');

        if (lastExpIndex + 35 < wordOrSentence.length) {
          result =
              wordOrSentence.substring(lastExpIndex + 3, lastExpIndex + 38);
          if (i + 1 < wordsAndSentences.length) {
            result += ' ${wordsAndSentences[i + 1]}';
          }
          break;
        }
      }
    }

    return result;
  }

  static String extractCountryName(String input) {
    if (input.contains("nigeria")) {
      return "Nigeria";
    } else if (input.contains("unitedkingdom") ||
        input.contains("britishcitizen")) {
      return "United Kingdom";
    } else if (input.contains("unitedstates") ||
        input.contains("nationalityusa")) {
      return "United States";
    } else {
      return "Country not found";
    }
  }

  static bool? parseDateByCountry(String inputString, String country) {
    switch (country.toLowerCase()) {
      case 'united kingdom':
        return parseBritishDate(inputString);
      case 'united states':
        return parseUSDate(inputString);
      case 'nigeria':
        return parseNigerianDate(inputString);
      default:
        print("Unsupported country: $country");
        return null;
    }
  }

  static bool? parseBritishDate(String inputString) {
    final monthYearMatches = RegExp(r"(\d{2})([a-zA-Z]+)\/([a-zA-Z]+)(\d{2})")
        .firstMatch(inputString);

    if (monthYearMatches != null) {
      final day = monthYearMatches.group(1);
      final englishMonth = monthYearMatches.group(2)!.toLowerCase();
      // final frenchMonth = monthYearMatches.group(3)!.toLowerCase();
      final year = monthYearMatches.group(4);

      print("English: $day $englishMonth 20$year");
      final isValid = isDateValid(englishMonth, '20$year');
      print('This is Valid $isValid');

      return isValid;
    }
    return false;
  }

  static bool? parseUSDate(String inputString) {
    final monthYearMatches =
        RegExp(r"(\d{2})([a-zA-Z]{3})(\d{4})").allMatches(inputString);
    final englishMonths = [
      "jan",
      "feb",
      "mar",
      "apr",
      "may",
      "jun",
      "jul",
      "aug",
      "sep",
      "oct",
      "nov",
      "dec"
    ];

    List<DateTime> parsedDates = [];

    for (var match in monthYearMatches) {
      final day = int.parse(match.group(1)!);
      final monthShortForm = match.group(2)!.toLowerCase();
      final year = int.parse(match.group(3)!);

      final englishIndex = englishMonths.indexOf(monthShortForm);

      if (englishIndex != -1) {
        final parsedDate = DateTime(year, englishIndex + 1, day);
        parsedDates.add(parsedDate);
      }
    }

    if (parsedDates.isNotEmpty) {
      parsedDates.sort((a, b) =>
          b.compareTo(a)); // Sort in descending order (newest date first)
      final newerDate = parsedDates.first;
      final isValid = isDateValid(newerDate.month.toString(), newerDate.year);
      print('This is Valid $isValid');
      return isValid;
    }
    return false;
  }

  static bool? parseNigerianDate(String inputString) {
    final monthYearMatches =
        RegExp(r"(\d{2})-(\d{2})-(\d{4})").firstMatch(inputString);

    if (monthYearMatches != null) {
      // final day = monthYearMatches.group(1);
      final month = monthYearMatches.group(2);
      final year = monthYearMatches.group(3);

      print("Month: $month");
      print("Year: $year");
      final isValid = isDateValid(month!, year);
      print('This is Valid $isValid');
      return isValid;
    }
    return false;
  }

  static bool isDateValid(String inputMonth, dynamic inputYear) {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    final monthMapping = {
      'jan': 1,
      'january': 1,
      'feb': 2,
      'february': 2,
      'mar': 3,
      'march': 3,
      'apr': 4,
      'april': 4,
      'may': 5,
      'jun': 6,
      'june': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'august': 8,
      'sep': 9,
      'september': 9,
      'oct': 10,
      'october': 10,
      'nov': 11,
      'november': 11,
      'dec': 12,
      'december': 12,
    };

    final normalizedInputMonth = inputMonth.toLowerCase();
    final numericInputMonth = monthMapping[normalizedInputMonth] ??
        int.tryParse(normalizedInputMonth);

    if (numericInputMonth != null &&
        inputYear is int &&
        inputYear >= currentYear) {
      if (inputYear > currentYear ||
          (inputYear == currentYear && numericInputMonth >= currentMonth)) {
        return true;
      }
    }

    return false;
  }
}
