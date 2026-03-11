/// Monthly performance data point for the admin bar chart
class MonthData {
  final String month;
  final int resolved;
  final int received;

  const MonthData(this.month, this.resolved, this.received);

  // TODO: Add fromFirestore factory when Firestore is connected
  // factory MonthData.fromFirestore(DocumentSnapshot doc) { ... }
}
