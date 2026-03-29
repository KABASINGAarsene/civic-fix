import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:district_direct/models/report_models.dart';

void main() {
  // ─────────────────────────── ReportStatus ───────────────────────────────────

  group('ReportStatus', () {
    test('contains all five expected values', () {
      expect(ReportStatus.values, hasLength(5));
      expect(ReportStatus.values, contains(ReportStatus.submitted));
      expect(ReportStatus.values, contains(ReportStatus.received));
      expect(ReportStatus.values, contains(ReportStatus.assigned));
      expect(ReportStatus.values, contains(ReportStatus.fieldVisit));
      expect(ReportStatus.values, contains(ReportStatus.resolved));
    });
  });

  // ─────────────────────────── ReportItem ─────────────────────────────────────

  group('ReportItem', () {
    test('stores all required fields correctly', () {
      const item = ReportItem(
        id: 'abc123',
        title: 'Broken streetlight',
        status: ReportStatus.received,
        category: 'Infrastructure',
        categoryIcon: Icons.lightbulb,
      );

      expect(item.id, equals('abc123'));
      expect(item.title, equals('Broken streetlight'));
      expect(item.status, equals(ReportStatus.received));
      expect(item.category, equals('Infrastructure'));
      expect(item.categoryIcon, equals(Icons.lightbulb));
    });

    test('uses sensible defaults for optional fields', () {
      const item = ReportItem(
        id: 'x',
        title: 'Test',
        status: ReportStatus.submitted,
        category: 'Other',
        categoryIcon: Icons.help,
      );

      expect(item.location, isNull);
      expect(item.date, isNull);
      expect(item.description, isNull);
    });

    test('respects explicitly set optional fields', () {
      const item = ReportItem(
        id: 'y',
        title: 'Pothole',
        status: ReportStatus.assigned,
        category: 'Roads',
        categoryIcon: Icons.route,
        location: 'KG 11 Ave',
        date: '2026-01-15',
        description: 'Large pothole near the school.',
      );

      expect(item.location, equals('KG 11 Ave'));
      expect(item.date, equals('2026-01-15'));
      expect(item.description, equals('Large pothole near the school.'));
    });
  });

  // ─────────────────────────── ReportDetailData ───────────────────────────────

  group('ReportDetailData.fromReportItem', () {
    const source = ReportItem(
      id: 'det1',
      title: 'Flooded road',
      status: ReportStatus.fieldVisit,
      category: 'Water',
      categoryIcon: Icons.water,
      description: 'Road flooded after rain.',
    );

    test('copies core fields from the source ReportItem', () {
      final detail = ReportDetailData.fromReportItem(
        source,
        location: 'KN 5 Rd',
        date: '2026-02-10',
      );

      expect(detail.id, equals(source.id));
      expect(detail.title, equals(source.title));
      expect(detail.status, equals(source.status));
      expect(detail.category, equals(source.category));
    });

    test('fills location and date fields from the named parameters', () {
      final detail = ReportDetailData.fromReportItem(
        source,
        location: 'KN 5 Rd',
        date: '2026-02-10',
      );

      expect(detail.location, equals('KN 5 Rd'));
      expect(detail.date, equals('2026-02-10'));
    });

    test('copies the category icon from the source item', () {
      final detail = ReportDetailData.fromReportItem(
        source,
        location: 'Anywhere',
        date: '2026-03-01',
      );

      expect(detail.categoryIcon, equals(Icons.water));
    });
  });

  // ─────────────────────────── MonthData ──────────────────────────────────────

  group('MonthData', () {
    test('stores month label, resolved count, and received count', () {
      const data = MonthData(month: 'Jan', resolved: 42, received: 60);

      expect(data.month, equals('Jan'));
      expect(data.resolved, equals(42));
      expect(data.received, equals(60));
    });

    test('works correctly with zero values', () {
      const data = MonthData(month: 'Feb', resolved: 0, received: 0);

      expect(data.resolved, equals(0));
      expect(data.received, equals(0));
    });
  });

  // ─────────────────────────── ChatMessage ────────────────────────────────────

  group('ChatMessage', () {
    test('creates an officer message with correct flags', () {
      const msg = ChatMessage(text: 'We will investigate.', isOfficer: true);

      expect(msg.text, equals('We will investigate.'));
      expect(msg.isOfficer, isTrue);
      expect(msg.isCitizen, isFalse);
    });

    test('creates a citizen message with an image attachment', () {
      const msg = ChatMessage(
        text: 'Here is a photo.',
        isCitizen: true,
        imageUrl: 'https://example.com/photo.jpg',
      );

      expect(msg.isCitizen, isTrue);
      expect(msg.imageUrl, equals('https://example.com/photo.jpg'));
    });

    test('stores a createdAt timestamp when provided', () {
      final now = DateTime(2026, 3, 1, 10, 30);
      final msg = ChatMessage(text: 'Hello', createdAt: now);

      expect(msg.createdAt, equals(now));
    });
  });

  // ─────────────────────────── AdminStat ──────────────────────────────────────

  group('AdminStat', () {
    test('stores label, value, trend, and styling fields', () {
      const stat = AdminStat(
        label: 'RECEIVED',
        value: '128',
        trend: 'Live',
        trendUp: true,
        color: Colors.blue,
      );

      expect(stat.label, equals('RECEIVED'));
      expect(stat.value, equals('128'));
      expect(stat.trend, equals('Live'));
      expect(stat.trendUp, isTrue);
      expect(stat.color, equals(Colors.blue));
    });

    test('accepts null for trendUp when trend direction is neutral', () {
      const stat = AdminStat(
        label: 'MY DISTRICT',
        value: 'Gasabo',
        trend: 'Check',
        color: Colors.grey,
      );

      expect(stat.trendUp, isNull);
    });
  });

  // ─────────────────────────── PriorityIssue ──────────────────────────────────

  group('PriorityIssue', () {
    test('stores all fields correctly', () {
      const issue = PriorityIssue(
        id: 'pri1',
        title: 'Collapsed bridge',
        district: 'Gasabo',
        priority: 'CRITICAL',
        status: ReportStatus.assigned,
      );

      expect(issue.id, equals('pri1'));
      expect(issue.title, equals('Collapsed bridge'));
      expect(issue.district, equals('Gasabo'));
      expect(issue.priority, equals('CRITICAL'));
      expect(issue.status, equals(ReportStatus.assigned));
    });
  });

  // ─────────────────────────── AdminIssue ─────────────────────────────────────

  group('AdminIssue', () {
    test('stores required fields and uses correct defaults', () {
      const issue = AdminIssue(id: 'ai1', title: 'No water supply');

      expect(issue.id, equals('ai1'));
      expect(issue.title, equals('No water supply'));
      expect(issue.status, equals(ReportStatus.submitted));
      expect(issue.category, isNull);
      expect(issue.district, isNull);
    });
  });
}
