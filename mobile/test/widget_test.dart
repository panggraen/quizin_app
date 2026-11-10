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

  Future<int> playAll(MockBackend b, int moduleId) async {
    final a = await b.startAttempt(moduleId);
    for (final q in a.questions) {
      await b.submitAnswer(a.attemptId, q.id, q.options.first.id);
    }
    await b.finish(a.attemptId);
    return a.attemptId;
  }

  test('modul 2 terkunci sampai modul 1 selesai', () async {
    final b = await loggedIn();
    expect(b.startAttempt(12), throwsA(isA<ApiException>()));
    await playAll(b, 11);
    final mods = await b.modules(1);
    expect(mods[1].status, 'available');
  });

  test('hadiah hanya sekali per modul', () async {
    final b = await loggedIn();
    final a1 = await b.startAttempt(11);
    for (final q in a1.questions) {
      await b.submitAnswer(a1.attemptId, q.id, q.options.first.id);
    }
    final r1 = await b.finish(a1.attemptId);
    expect(r1.xpAwarded, r1.correctCount * 10);
    expect(r1.coinsAwarded, r1.correctCount);
    final xpAfterFirst = (await b.profile()).totalXp;

    // finish dipanggil dua kali: hadiah tidak ganda
    await b.finish(a1.attemptId);
    expect((await b.profile()).totalXp, xpAfterFirst);

    // ulang modul: tidak ada hadiah tambahan
    final a2 = await b.startAttempt(11);
    for (final q in a2.questions) {
      await b.submitAnswer(a2.attemptId, q.id, q.options.first.id);
    }
    final r2 = await b.finish(a2.attemptId);
    expect(r2.xpAwarded, 0);
    expect((await b.profile()).totalXp, xpAfterFirst);
  });

  test('pembahasan hanya setelah kuis selesai', () async {
    final b = await loggedIn();
    final a = await b.startAttempt(11);
    expect(b.review(a.attemptId), throwsA(isA<ApiException>()));
  });

  test('pembelian karakter: saldo kurang ditolak, tidak bisa beli dua kali', () async {
    final b = MockBackend();
    await b.register(
        name: 'Baru', email: 'baru@quizin.test', phone: '+620000', password: 'password123');
    expect(b.purchase(2), throwsA(isA<ApiException>()));

    final demo = await loggedIn();
    await demo.purchase(2);
    expect(demo.purchase(2), throwsA(isA<ApiException>()));
    expect((await demo.profile()).coins, 50);
  });
}
