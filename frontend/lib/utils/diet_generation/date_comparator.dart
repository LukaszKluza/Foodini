int dateComparator(DateTime a, DateTime b) {

  final aDate = DateTime(a.year, a.month, a.day);
  final bDate = DateTime(b.year, b.month, b.day);
  return aDate.compareTo(bDate);
}
