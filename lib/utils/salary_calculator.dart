class SalaryCalculator {
  static const double monthlyFixedSalary = 200000.0;
  static const int monthlyTargetFiles = 80;
  static const int workingDaysPerMonth = 20;
  static const int dailyTargetFiles = 4;

  static double get fileValue => monthlyFixedSalary / monthlyTargetFiles;

  static double calculateDeduction({required int totalErrors, required int missedErrors}) {
    if (totalErrors == 0 || missedErrors == 0) return 0.0;
    return (fileValue / totalErrors) * missedErrors;
  }

  static double calculateFinalPayout({required double baseSalary, required double totalDeductions}) {
    return baseSalary - totalDeductions;
  }
}
