import 'package:quizin_app/core/network/api_exception.dart';
import 'package:quizin_app/models/category_model.dart';
import 'package:quizin_app/models/character_model.dart';
import 'package:quizin_app/models/leaderboard_model.dart';
import 'package:quizin_app/models/material_model.dart';
import 'package:quizin_app/models/progress_model.dart';
import 'package:quizin_app/models/question_model.dart';
import 'package:quizin_app/models/quiz_model.dart';
import 'package:quizin_app/models/subject_model.dart';
import 'package:quizin_app/models/user_model.dart';
import 'package:quizin_app/services/auth_service.dart';
import 'package:quizin_app/services/material_service.dart';
import 'package:quizin_app/services/profile_service.dart';
import 'package:quizin_app/services/quiz_service.dart';
import 'package:quizin_app/services/shop_service.dart';

// =============================================================
// DATA CONTOH (DUMMY) - menggantikan Laravel sementara.
// Aturan bisnis di sini meniru aturan server di PRD supaya UI
// bisa dicoba. Semua ini diganti ApiService saat backend siap.
// =============================================================

class _MockUser {
  _MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final int id;
  String name;
  final String email;
  final String phone;
  final String password;
  int activeCharacterId = 1;
  final Set<int> ownedCharacters = {1};
  final List<int> materialsDone = [];
  final Map<int, int> moduleBest = {}; // moduleId -> nilai terbaik (%)
  final Map<int, int> rewardXp = {}; // moduleId -> XP (sekali per modul)
  final Map<int, int> rewardCoins = {}; // moduleId -> koin (sekali per modul)
  final Map<int, int> purchases = {}; // characterId -> harga dibayar
  final List<ProgressItemModel> history = [];
}

class _Q {
  const _Q(this.id, this.text, this.options, this.correct, this.explanation);
  final int id;
  final String text;
  final List<String> options;
  final int correct; // indeks 0..3, TIDAK pernah dikirim sebelum dijawab
  final String explanation;
}

class _Attempt {
  _Attempt(this.id, this.userId, this.moduleId, this.questions);
  final int id;
  final int userId;
  final int moduleId;
  final List<_Q> questions;
  final Map<int, int> answers = {}; // questionId -> optionId
  String status = 'in_progress';
  AttemptResultModel? result;
}

class MockBackend
    implements AuthService, ContentService, QuizService, ProfileService, ShopService {
  static const int materialXp = 15; // keputusan tim: 15 XP per materi (pertama kali)
  static const int xpPerCorrect = 10;
  static const int coinsPerCorrect = 1;
  static const int _modulesPerMaterial = 2;

  static const List<({int id, String name})> _categories = [
    (id: 1, name: 'IPA'),
    (id: 2, name: 'Sejarah'),
    (id: 3, name: 'Matematika'),
    (id: 4, name: 'Teknologi'),
  ];

  static const List<({int id, int categoryId, String name})> _subjects = [
    (id: 1, categoryId: 1, name: 'Biologi'),
    (id: 2, categoryId: 1, name: 'Fisika'),
    (id: 3, categoryId: 1, name: 'Kimia'),
    (id: 4, categoryId: 2, name: 'Sejarah Indonesia'),
    (id: 5, categoryId: 3, name: 'Aljabar'),
    (id: 6, categoryId: 4, name: 'Dasar Komputer'),
  ];

  static const List<({int id, int subjectId, String title, String content})> _materials = [
    (
      id: 1,
      subjectId: 1,
      title: 'Fotosintesis',
      content:
          'Fotosintesis adalah proses tumbuhan hijau membuat makanan sendiri. Dengan bantuan klorofil, tumbuhan menyerap cahaya matahari, air, dan karbon dioksida, lalu mengubahnya menjadi glukosa dan oksigen.'
    ),
    (
      id: 2,
      subjectId: 1,
      title: 'Sel',
      content:
          'Sel adalah unit terkecil penyusun makhluk hidup. [Konten contoh: isi sebenarnya diisi admin lewat Panel Filament.]'
    ),
    (
      id: 3,
      subjectId: 2,
      title: 'Gerak Lurus',
      content:
          'Gerak lurus adalah gerak benda pada lintasan lurus. [Konten contoh: isi sebenarnya diisi admin.]'
    ),
    (
      id: 4,
      subjectId: 3,
      title: 'Zat',
      content:
          'Zat adalah segala sesuatu yang memiliki massa dan menempati ruang. [Konten contoh: isi sebenarnya diisi admin.]'
    ),
    (
      id: 5,
      subjectId: 3,
      title: 'Senyawa',
      content:
          'Senyawa merupakan zat kimia murni yang terbentuk dari dua atau lebih unsur dengan perbandingan massa yang tetap melalui reaksi kimia.'
    ),
    (
      id: 6,
      subjectId: 4,
      title: 'Kerajaan Hindu-Buddha',
      content:
          'Kerajaan Hindu-Buddha adalah kerajaan awal di Nusantara. [Konten contoh: isi sebenarnya diisi admin.]'
    ),
    (
      id: 7,
      subjectId: 5,
      title: 'Persamaan Linear',
      content:
          'Persamaan linear adalah persamaan dengan variabel berpangkat satu. [Konten contoh: isi sebenarnya diisi admin.]'
    ),
    (
      id: 8,
      subjectId: 6,
      title: 'Perangkat Keras',
      content:
          'Perangkat keras adalah bagian fisik komputer. [Konten contoh: isi sebenarnya diisi admin.]'
    ),
  ];

  static const List<({int id, String name, String description, int price})> _characters = [
    (id: 1, name: 'Nimbi', description: 'Karakter awal yang selalu menemani belajarmu.', price: 0),
    (id: 2, name: 'Clumbi', description: 'Salah satu karakter yang membuat langit tertawa.', price: 250),
    (id: 3, name: 'Clambi', description: 'Salah satu karakter yang memiliki emosi.', price: 250),
  ];

  static const List<({int id, String name, String description, int need})> _badges = [
    (id: 1, name: 'Pemula', description: 'Selesaikan 1 modul', need: 1),
    (id: 2, name: 'Pelajar Rajin', description: 'Selesaikan 3 modul', need: 3),
    (id: 3, name: 'Jagoan Kuis', description: 'Selesaikan 5 modul', need: 5),
  ];

  static const List<({int id, String name, int xp})> _others = [
    (id: 101, name: 'Rania', xp: 5890),
    (id: 102, name: 'Dimas', xp: 4970),
    (id: 103, name: 'Sashti', xp: 4310),
    (id: 104, name: 'Daffa', xp: 3640),
    (id: 105, name: 'Raffa', xp: 3500),
    (id: 106, name: 'Affa', xp: 3500),
  ];

  final List<_MockUser> _users = [];
  final Map<int, _Attempt> _attempts = {};
  _MockUser? _me;
  int _userSeq = 0;
  int _attemptSeq = 0;

  MockBackend() {
    // Akun contoh (DUMMY). 300 koin awal hanya agar toko bisa dicoba.
    final demo = _MockUser(
      id: ++_userSeq,
      name: 'Oncom',
      email: 'demo@quizin.test',
      phone: '+6281234567890',
      password: 'password123',
    );
    demo.rewardCoins[0] = 300;
    _users.add(demo);
  }

  Future<void> _wait() => Future<void>.delayed(const Duration(milliseconds: 250));

  _MockUser get _user {
    final u = _me;
    if (u == null) throw ApiException('Silakan masuk terlebih dahulu.');
    return u;
  }

  int _totalXp(_MockUser u) =>
      u.rewardXp.values.fold<int>(0, (a, b) => a + b) + u.materialsDone.length * materialXp;

  int _coins(_MockUser u) =>
      u.rewardCoins.values.fold<int>(0, (a, b) => a + b) -
      u.purchases.values.fold<int>(0, (a, b) => a + b);

  UserModel _toModel(_MockUser u) {
    final xp = _totalXp(u);
    return UserModel(
      id: u.id,
      name: u.name,
      email: u.email,
      phone: u.phone,
      totalXp: xp,
      coins: _coins(u),
      level: xp ~/ 100 + 1,
      activeCharacterId: u.activeCharacterId,
      materialsCompleted: u.materialsDone.length,
      modulesCompleted: u.moduleBest.length,
    );
  }

  String _path(int materialId) {
    final m = _materials.firstWhere((x) => x.id == materialId);
    final s = _subjects.firstWhere((x) => x.id == m.subjectId);
    final c = _categories.firstWhere((x) => x.id == s.categoryId);
    return '${c.name}-${s.name}-${m.title}';
  }

  // ---------------- AUTH ----------------
  @override
  Future<UserModel> login(String email, String password) async {
    await _wait();
    final found = _users.where(
        (u) => u.email == email.trim().toLowerCase() && u.password == password);
    if (found.isEmpty) throw ApiException('Email atau kata sandi salah.');
    final user = found.first;
    _me = user;
    return _toModel(user);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _wait();
    final mail = email.trim().toLowerCase();
    if (_users.any((u) => u.email == mail)) {
      throw ApiException('Email sudah terdaftar.');
    }
    final user = _MockUser(
      id: ++_userSeq,
      name: name.trim(),
      email: mail,
      phone: phone.trim(),
      password: password,
    );
    _users.add(user);
    _me = user;
    return _toModel(user);
  }

  @override
  Future<void> logout() async {
    await _wait();
    _me = null;
  }

  @override
  Future<UserModel> me() async {
    await _wait();
    return _toModel(_user);
  }

  // ---------------- MATERI ----------------
  @override
  Future<List<CategoryModel>> categories() async {
    await _wait();
    final u = _user;
    return _categories.map((c) {
      final subjectIds =
          _subjects.where((s) => s.categoryId == c.id).map((s) => s.id).toSet();
      final mats = _materials.where((m) => subjectIds.contains(m.subjectId)).toList();
      return CategoryModel(
        id: c.id,
        name: c.name,
        materialsDone: mats.where((m) => u.materialsDone.contains(m.id)).length,
        materialsTotal: mats.length,
      );
    }).toList();
  }

  @override
  Future<List<SubjectModel>> subjects(int categoryId) async {
    await _wait();
    final u = _user;
    return _subjects.where((s) => s.categoryId == categoryId).map((s) {
      final mats = _materials.where((m) => m.subjectId == s.id).toList();
      return SubjectModel(
        id: s.id,
        categoryId: s.categoryId,
        name: s.name,
        materialsDone: mats.where((m) => u.materialsDone.contains(m.id)).length,
        materialsTotal: mats.length,
      );
    }).toList();
  }

  MaterialModel _materialModel(
      ({int id, int subjectId, String title, String content}) m, _MockUser u) {
    return MaterialModel(
      id: m.id,
      subjectId: m.subjectId,
      title: m.title,
      content: m.content,
      isCompleted: u.materialsDone.contains(m.id),
    );
  }

  @override
  Future<List<MaterialModel>> materials(int subjectId) async {
    await _wait();
    final u = _user;
    return _materials
        .where((m) => m.subjectId == subjectId)
        .map((m) => _materialModel(m, u))
        .toList();
  }

  @override
  Future<MaterialModel> material(int materialId) async {
    await _wait();
    final u = _user;
    final found = _materials.where((m) => m.id == materialId);
    if (found.isEmpty) throw ApiException('Materi tidak ditemukan.');
    return _materialModel(found.first, u);
  }

  @override
  Future<MaterialCompletionModel> completeMaterial(int materialId) async {
    await _wait();
    final u = _user;
    if (!_materials.any((m) => m.id == materialId)) {
      throw ApiException('Materi tidak ditemukan.');
    }
    if (u.materialsDone.contains(materialId)) {
      return const MaterialCompletionModel(xpAwarded: 0, alreadyCompleted: true);
    }
    u.materialsDone.add(materialId);
    u.history.insert(
      0,
      ProgressItemModel(
        title: 'Anda sudah menyelesaikan materi',
        subtitle: _path(materialId),
        type: 'material',
      ),
    );
    return const MaterialCompletionModel(xpAwarded: materialXp, alreadyCompleted: false);
  }

  // ---------------- KUIS ----------------
  List<_Q> _questionsFor(int moduleId) {
    final materialId = moduleId ~/ 10;
    final m = _materials.firstWhere((x) => x.id == materialId);
    if (materialId == 1) {
      const bank = [
        ['Apa fungsi utama klorofil pada tumbuhan?', 'Menyerap air', 'Menangkap cahaya matahari untuk fotosintesis', 'Menyimpan cadangan makanan', 'Melindungi sel dari sinar UV', '1', 'Klorofil menangkap energi cahaya yang dipakai untuk fotosintesis.'],
        ['Apa hasil utama fotosintesis?', 'Karbon dioksida dan air', 'Glukosa dan oksigen', 'Protein dan lemak', 'Nitrogen dan air', '1', 'Fotosintesis menghasilkan glukosa sebagai makanan dan oksigen sebagai gas buangan.'],
        ['Gas apa yang diserap tumbuhan untuk fotosintesis?', 'Oksigen', 'Nitrogen', 'Karbon dioksida', 'Hidrogen', '2', 'Tumbuhan menyerap karbon dioksida dari udara lewat stomata.'],
        ['Di bagian sel mana fotosintesis berlangsung?', 'Mitokondria', 'Inti sel', 'Ribosom', 'Kloroplas', '3', 'Kloroplas mengandung klorofil sehingga menjadi tempat fotosintesis.'],
        ['Apa sumber energi utama fotosintesis?', 'Panas bumi', 'Air hujan', 'Cahaya matahari', 'Angin', '2', 'Energi cahaya matahari diubah menjadi energi kimia dalam glukosa.'],
      ];
      return List.generate(5, (i) {
        final b = bank[i];
        return _Q(moduleId * 100 + i + 1, b[0], [b[1], b[2], b[3], b[4]], int.parse(b[5]), b[6]);
      });
    }
    return List.generate(5, (i) {
      final k = i + 1;
      return _Q(
        moduleId * 100 + k,
        '[DUMMY] Soal $k tentang ${m.title}?',
        const ['Jawaban A', 'Jawaban B', 'Jawaban C', 'Jawaban D'],
        (k + moduleId) % 4,
        '[DUMMY] Pembahasan soal $k. Isi asli dibuat admin di Panel Filament.',
      );
    });
  }

  @override
  Future<List<QuizModuleModel>> modules(int materialId) async {
    await _wait();
    final u = _user;
    if (!_materials.any((m) => m.id == materialId)) {
      throw ApiException('Materi tidak ditemukan.');
    }
    return List.generate(_modulesPerMaterial, (i) {
      final n = i + 1;
      final id = materialId * 10 + n;
      final best = u.moduleBest[id];
      final prevDone = n == 1 || u.moduleBest.containsKey(id - 1);
      return QuizModuleModel(
        id: id,
        materialId: materialId,
        moduleNumber: n,
        title: 'Modul $n',
        status: best != null ? 'completed' : (prevDone ? 'available' : 'locked'),
        bestScore: best,
      );
    });
  }

  @override
  Future<AttemptModel> startAttempt(int moduleId) async {
    await _wait();
    final u = _user;
    final materialId = moduleId ~/ 10;
    final n = moduleId % 10;
    if (!_materials.any((m) => m.id == materialId) || n < 1 || n > _modulesPerMaterial) {
      throw ApiException('Modul tidak ditemukan.');
    }
    if (n > 1 && !u.moduleBest.containsKey(moduleId - 1)) {
      throw ApiException('Modul masih terkunci. Selesaikan modul sebelumnya dulu.');
    }
    // Sesi lama untuk modul yang sama dianggap ditinggalkan.
    for (final a in _attempts.values) {
      if (a.userId == u.id && a.moduleId == moduleId && a.status == 'in_progress') {
        a.status = 'abandoned';
      }
    }
    final qs = _questionsFor(moduleId);
    final attempt = _Attempt(++_attemptSeq, u.id, moduleId, qs);
    _attempts[attempt.id] = attempt;
    return AttemptModel(
      attemptId: attempt.id,
      questions: [
        for (var i = 0; i < qs.length; i++)
          QuestionModel(
            id: qs[i].id,
            number: i + 1,
            text: qs[i].text,
            options: [
              for (var j = 0; j < 4; j++)
                OptionModel(
                  id: qs[i].id * 10 + j + 1,
                  label: 'ABCD'[j],
                  text: qs[i].options[j],
                ),
            ],
          ),
      ],
    );
  }

  _Attempt _attemptOf(int attemptId, _MockUser u) {
    final a = _attempts[attemptId];
    if (a == null || a.userId != u.id) throw ApiException('Sesi kuis tidak ditemukan.');
    return a;
  }

  @override
  Future<AnswerResultModel> submitAnswer(int attemptId, int questionId, int optionId) async {
    await _wait();
    final a = _attemptOf(attemptId, _user);
    if (a.status != 'in_progress') throw ApiException('Sesi kuis ini sudah tidak aktif.');
    final matches = a.questions.where((q) => q.id == questionId);
    if (matches.isEmpty) throw ApiException('Soal bukan bagian dari sesi ini.');
    final q = matches.first;
    final optionIndex = optionId % 10 - 1;
    if (optionId ~/ 10 != q.id || optionIndex < 0 || optionIndex > 3) {
      throw ApiException('Pilihan jawaban tidak valid.');
    }
    if (a.answers.containsKey(q.id)) throw ApiException('Soal ini sudah dijawab.');
    a.answers[q.id] = optionId;
    return AnswerResultModel(
      isCorrect: optionIndex == q.correct,
      correctOptionId: q.id * 10 + q.correct + 1,
      explanation: q.explanation,
    );
  }

  @override
  Future<AttemptResultModel> finish(int attemptId) async {
    await _wait();
    final u = _user;
    final a = _attemptOf(attemptId, u);
    // Permintaan finish berulang tidak menggandakan hadiah.
    if (a.status == 'completed') return a.result!;
    if (a.status != 'in_progress') throw ApiException('Sesi kuis ini sudah tidak aktif.');
    if (a.answers.length < a.questions.length) {
      throw ApiException('Jawab semua soal dulu sebelum menyelesaikan kuis.');
    }
    final correct =
        a.questions.where((q) => a.answers[q.id] == q.id * 10 + q.correct + 1).length;
    final total = a.questions.length;
    final score = (correct * 100 / total).round();
    final first = !u.moduleBest.containsKey(a.moduleId);
    if (first) {
      u.moduleBest[a.moduleId] = score;
      u.rewardXp[a.moduleId] = correct * xpPerCorrect;
      u.rewardCoins[a.moduleId] = correct * coinsPerCorrect;
    } else if (score > u.moduleBest[a.moduleId]!) {
      u.moduleBest[a.moduleId] = score;
    }
    u.history.insert(
      0,
      ProgressItemModel(
        title: 'Anda sudah menyelesaikan kuis',
        subtitle: '${_path(a.moduleId ~/ 10)} · Modul ${a.moduleId % 10} · $score%',
        type: 'quiz',
      ),
    );
    final result = AttemptResultModel(
      attemptId: a.id,
      correctCount: correct,
      totalQuestions: total,
      scorePercent: score,
      xpAwarded: first ? correct * xpPerCorrect : 0,
      coinsAwarded: first ? correct * coinsPerCorrect : 0,
      rewardGiven: first,
    );
    a.status = 'completed';
    a.result = result;
    return result;
  }

  @override
  Future<List<ReviewItemModel>> review(int attemptId) async {
    await _wait();
    final a = _attemptOf(attemptId, _user);
    if (a.status != 'completed') {
      throw ApiException('Pembahasan hanya tersedia setelah kuis selesai.');
    }
    return [
      for (var i = 0; i < a.questions.length; i++)
        () {
          final q = a.questions[i];
          final chosen = a.answers[q.id]! % 10 - 1;
          return ReviewItemModel(
            number: i + 1,
            question: q.text,
            userAnswer: q.options[chosen],
            correctAnswer: q.options[q.correct],
            isCorrect: chosen == q.correct,
            explanation: q.explanation,
          );
        }(),
    ];
  }

  // ---------------- PROFIL ----------------
  @override
  Future<UserModel> profile() async {
    await _wait();
    return _toModel(_user);
  }

  @override
  Future<UserModel> updateName(String name) async {
    await _wait();
    final u = _user;
    final clean = name.trim();
    if (clean.length < 2) throw ApiException('Nama minimal 2 karakter.');
    u.name = clean;
    return _toModel(u);
  }

  @override
  Future<List<LeaderboardEntryModel>> leaderboard() async {
    await _wait();
    final me = _user;
    final rows = <({int id, String name, int xp, int characterId, bool isMe})>[
      for (final o in _others) (id: o.id, name: o.name, xp: o.xp, characterId: 1, isMe: false),
      (id: me.id, name: me.name, xp: _totalXp(me), characterId: me.activeCharacterId, isMe: true),
    ];
    // Urut XP menurun, seri: users.id menaik.
    rows.sort((a, b) => b.xp != a.xp ? b.xp.compareTo(a.xp) : a.id.compareTo(b.id));
    return [
      for (var i = 0; i < rows.length; i++)
        LeaderboardEntryModel(
          rank: i + 1,
          userId: rows[i].id,
          name: rows[i].name,
          level: rows[i].xp ~/ 100 + 1,
          totalXp: rows[i].xp,
          characterId: rows[i].characterId,
          isMe: rows[i].isMe,
        ),
    ];
  }

  @override
  Future<ProgressModel> progress() async {
    await _wait();
    final u = _user;
    return ProgressModel(
      totalXp: _totalXp(u),
      totalCoins: _coins(u),
      items: List<ProgressItemModel>.from(u.history),
      badges: [
        for (final b in _badges)
          BadgeModel(
            id: b.id,
            name: b.name,
            description: b.description,
            requiredModules: b.need,
            isEarned: u.moduleBest.length >= b.need,
          ),
      ],
    );
  }

  // ---------------- TOKO ----------------
  CharacterModel _characterModel(
      ({int id, String name, String description, int price}) c, _MockUser u) {
    return CharacterModel(
      id: c.id,
      name: c.name,
      description: c.description,
      priceCoins: c.price,
      isDefault: c.price == 0,
      isOwned: c.price == 0 || u.ownedCharacters.contains(c.id),
      isActive: u.activeCharacterId == c.id,
    );
  }

  @override
  Future<List<CharacterModel>> characters() async {
    await _wait();
    final u = _user;
    return _characters.map((c) => _characterModel(c, u)).toList();
  }

  @override
  Future<CharacterModel> purchase(int characterId) async {
    await _wait();
    final u = _user;
    final found = _characters.where((c) => c.id == characterId);
    if (found.isEmpty) throw ApiException('Karakter tidak ditemukan.');
    final c = found.first;
    if (c.price == 0 || u.ownedCharacters.contains(c.id)) {
      throw ApiException('Karakter ini sudah kamu miliki.');
    }
    if (_coins(u) < c.price) throw ApiException('Koin kamu belum cukup.');
    u.purchases[c.id] = c.price;
    u.ownedCharacters.add(c.id);
    return _characterModel(c, u);
  }

  @override
  Future<void> setActiveCharacter(int characterId) async {
    await _wait();
    final u = _user;
    final found = _characters.where((c) => c.id == characterId);
    if (found.isEmpty) throw ApiException('Karakter tidak ditemukan.');
    if (found.first.price != 0 && !u.ownedCharacters.contains(characterId)) {
      throw ApiException('Beli karakter ini dulu sebelum memakainya.');
    }
    u.activeCharacterId = characterId;
  }
}
