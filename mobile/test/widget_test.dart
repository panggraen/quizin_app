import 'package:flutter_test/flutter_test.dart';
import 'package:quizin_app/core/network/api_exception.dart';
import 'package:quizin_app/services/mock/mock_backend.dart';

/// Menguji aturan bisnis pada MockBackend (meniru aturan server).
void main() {
  Future<MockBackend> loggedIn() async {
    final b = MockBackend();
    await b.login('demo@quizin.test', 'password123');
    return b;
  }

  /// Menjawab semua soal dengan pilihan ke-[optionIndex] (0 = A ... 3 = D).
  /// Di modul 101, pilihan B (indeks 1) benar untuk soal 1 dan 2.
  Future<int> playAll(MockBackend b, int moduleId, {int optionIndex = 0}) async {
    final a = await b.startAttempt(moduleId);
    for (final q in a.questions) {
      await b.submitAnswer(a.attemptId, q.id, q.options[optionIndex].id);
    }
    await b.finish(a.attemptId);
    return a.attemptId;
  }

  test('modul 2 terkunci sampai modul 1 selesai', () async {
    final b = await loggedIn();
    await expectLater(b.startAttempt(102), throwsA(isA<ApiException>()));
    await playAll(b, 101);
    final mods = await b.modules(1);
    expect(mods[1].status, 'available');
  });

  test('Biologi langsung berisi modul 1..12 berurutan', () async {
    final b = await loggedIn();
    final mods = await b.modules(1);
    expect(mods.length, 12);
    expect([for (final m in mods) m.moduleNumber], List.generate(12, (i) => i + 1));
    expect(mods.first.status, 'available');
    expect(mods.skip(1).every((m) => m.status == 'locked'), isTrue);
  });

  test('hadiah hanya sekali per modul', () async {
    final b = await loggedIn();
    final a1 = await b.startAttempt(101);
    for (final q in a1.questions) {
      await b.submitAnswer(a1.attemptId, q.id, q.options[1].id);
    }
    final r1 = await b.finish(a1.attemptId);
    expect(r1.correctCount, greaterThan(0));
    expect(r1.xpAwarded, r1.correctCount * 10);
    expect(r1.coinsAwarded, r1.correctCount);
    final xpAfterFirst = (await b.profile()).totalXp;

    // finish dipanggil dua kali: hadiah tidak ganda
    await b.finish(a1.attemptId);
    expect((await b.profile()).totalXp, xpAfterFirst);

    // ulang modul: tidak ada hadiah tambahan
    final a2 = await b.startAttempt(101);
    for (final q in a2.questions) {
      await b.submitAnswer(a2.attemptId, q.id, q.options[1].id);
    }
    final r2 = await b.finish(a2.attemptId);
    expect(r2.xpAwarded, 0);
    expect((await b.profile()).totalXp, xpAfterFirst);
  });

  test('pembahasan hanya setelah kuis selesai', () async {
    final b = await loggedIn();
    final a = await b.startAttempt(101);
    await expectLater(b.review(a.attemptId), throwsA(isA<ApiException>()));
  });

  test('umpan balik jawaban berisi alasan pilihan yang dipilih', () async {
    final b = await loggedIn();
    final a = await b.startAttempt(101);
    final q = a.questions.first; // soal 1: jawaban benar = B

    final wrong = await b.submitAnswer(a.attemptId, q.id, q.options[0].id);
    expect(wrong.isCorrect, isFalse);
    expect(wrong.correctOptionId, q.options[1].id);
    expect(wrong.chosenExplanation, startsWith('Salah.'));
    expect(wrong.explanation, startsWith('Benar.'));

    // soal yang sama tidak bisa dijawab dua kali
    await expectLater(
        b.submitAnswer(a.attemptId, q.id, q.options[1].id), throwsA(isA<ApiException>()));
  });

  test('pembahasan memuat 4 pilihan, tepat 1 benar, dan pilihan pengguna ditandai', () async {
    final b = await loggedIn();
    final attemptId = await playAll(b, 101, optionIndex: 1);
    final items = await b.review(attemptId);
    expect(items.length, 5);
    for (final it in items) {
      expect(it.options.length, 4);
      expect(it.options.where((o) => o.isCorrect).length, 1);
      expect(it.options.where((o) => o.isChosen).length, 1);
      expect(it.options.every((o) => o.reason.isNotEmpty), isTrue);
      // Pilihan B (indeks 1) selalu yang dipilih di sini.
      expect(it.options[1].isChosen, isTrue);
    }
  });

  test('semua soal bank punya 4 pilihan (modul 101-103)', () async {
    final b = await loggedIn();
    await playAll(b, 101);
    await playAll(b, 102);
    final a = await b.startAttempt(103);
    expect(a.questions.length, 5);
    expect(a.questions.every((q) => q.options.length == 4), isTrue);
  });

  test('pembelian karakter: saldo kurang ditolak, tidak bisa beli dua kali', () async {
    final b = MockBackend();
    await b.register(
        name: 'Baru', email: 'baru@quizin.test', phone: '+620000', password: 'password123');
    await expectLater(b.purchase(2), throwsA(isA<ApiException>()));

    final demo = await loggedIn();
    await demo.purchase(2);
    await expectLater(demo.purchase(2), throwsA(isA<ApiException>()));
    expect((await demo.profile()).coins, 150); // 300 koin awal - 150 (Headphone)
  });
}