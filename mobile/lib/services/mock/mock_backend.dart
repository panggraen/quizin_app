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

typedef _QuizItem = ({
  String question,
  List<String> options,
  int correct,
  List<String> reasons,
});

class _Q {
  const _Q(
    this.id,
    this.text,
    this.options,
    this.correct,
    this.explanation, {
    required this.reasons,
  });
  final int id;
  final String text;
  final List<String> options;
  final int correct; // indeks 0..3, TIDAK pernah dikirim sebelum dijawab
  final String explanation; // alasan jawaban benar (dipakai di halaman pembahasan)

  /// Alasan per pilihan A..D: kenapa pilihan itu benar / salah.
  final List<String> reasons;
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
  // Contoh: tiap materi punya 6 modul, jadi Biologi (2 materi) = modul 1..12.
  // ID modul = subjectId * 100 + nomor modul (nomor urut sepanjang bidang).
  static const int _modulesPerMaterial = 6;

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
    (id: 1, name: 'Nimbi', description: 'Maskot awan tanpa aksesori.', price: 0),
    (id: 2, name: 'Headphone', description: 'Belajar sambil dengar musik favorit.', price: 150),
    (id: 3, name: 'Mahkota', description: 'Untuk raja dan ratu kuis.', price: 500),
    (id: 4, name: 'Topi Wisuda', description: 'Tampil cerdas seperti lulusan terbaik.', price: 250),
    (id: 6, name: 'Topi Penyihir', description: 'Sihir pengetahuan di kepalamu.', price: 300),
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

  // ====== TEMPAT MENGISI SOAL & ALASAN ======
  // Kunci = ID modul = ID bidang * 100 + nomor modul.
  //   101 = Biologi modul 1, 102 = Biologi modul 2, 201 = Fisika modul 1, dst.
  // Modul yang tidak ada di sini memakai soal [DUMMY].
  //
  // question : teks soal
  // options  : 4 pilihan (A, B, C, D)
  // correct  : indeks jawaban benar (0 = A, 1 = B, 2 = C, 3 = D)
  // reasons  : 4 alasan, urutannya sama dengan options. Alasan untuk jawaban
  //            benar = kenapa benar; alasan lainnya = kenapa salah.
  static const Map<int, List<_QuizItem>> _quizBank = {
    // Biologi - Modul 1 (Fotosintesis: dasar)
    101: [
        (
          question: 'Apa fungsi utama klorofil pada tumbuhan?',
          options: [
            'Menyerap air',
            'Menangkap cahaya matahari untuk fotosintesis',
            'Menyimpan cadangan makanan',
            'Melindungi sel dari sinar UV',
          ],
          correct: 1,
          reasons: [
            'Salah. Air diserap oleh akar dari dalam tanah, lalu diangkut ke daun lewat pembuluh xilem. Klorofil tidak ikut menyerap air; klorofil hanya memakai air itu sebagai bahan baku fotosintesis.',
            'Benar. Klorofil adalah pigmen hijau di dalam kloroplas yang menyerap energi cahaya matahari. Energi inilah yang dipakai untuk mengubah air dan karbon dioksida menjadi glukosa dan oksigen. Tanpa klorofil, fotosintesis tidak bisa berjalan.',
            'Salah. Cadangan makanan disimpan tumbuhan dalam bentuk amilum di bagian seperti akar, umbi, batang, atau biji. Klorofil bertugas menangkap cahaya, bukan menyimpan makanan.',
            'Salah. Perlindungan dari sinar UV berkaitan dengan lapisan pelindung dan pigmen lain pada daun, bukan fungsi utama klorofil. Klorofil justru memanfaatkan cahaya, bukan menahannya.',
          ],
        ),
        (
          question: 'Apa hasil utama fotosintesis?',
          options: [
            'Karbon dioksida dan air',
            'Glukosa dan oksigen',
            'Protein dan lemak',
            'Nitrogen dan air',
          ],
          correct: 1,
          reasons: [
            'Salah. Karbon dioksida dan air adalah bahan baku yang masuk ke proses fotosintesis, bukan hasilnya. Keduanya habis dipakai untuk membentuk glukosa.',
            'Benar. Tumbuhan memakai karbon dioksida dan air sebagai bahan baku. Dengan bantuan cahaya, keduanya diubah menjadi glukosa sebagai makanan tumbuhan, dan oksigen yang dilepas ke udara sebagai gas buangan.',
            'Salah. Protein dan lemak dibuat tumbuhan sesudahnya, memakai glukosa dan unsur lain seperti nitrogen dari tanah. Keduanya bukan hasil langsung fotosintesis.',
            'Salah. Nitrogen diserap akar dari tanah dalam bentuk senyawa seperti nitrat, bukan dihasilkan fotosintesis. Air juga bahan baku, bukan hasil.',
          ],
        ),
        (
          question: 'Gas apa yang diserap tumbuhan untuk fotosintesis?',
          options: ['Oksigen', 'Nitrogen', 'Karbon dioksida', 'Hidrogen'],
          correct: 2,
          reasons: [
            'Salah. Oksigen justru dilepaskan tumbuhan sebagai hasil fotosintesis. Tumbuhan memang memakai oksigen, tetapi untuk respirasi, bukan sebagai bahan baku fotosintesis.',
            'Salah. Walaupun nitrogen adalah gas terbanyak di udara, tumbuhan tidak memakainya langsung untuk fotosintesis. Nitrogen diambil akar dari tanah dalam bentuk senyawa.',
            'Benar. Karbon dioksida diserap dari udara lewat stomata, yaitu pori-pori kecil di permukaan daun. Gas ini menjadi bahan baku utama pembuatan glukosa.',
            'Salah. Hidrogen bebas hampir tidak ada di udara. Hidrogen untuk membentuk glukosa berasal dari air yang diserap akar.',
          ],
        ),
        (
          question: 'Di bagian sel mana fotosintesis berlangsung?',
          options: ['Mitokondria', 'Inti sel', 'Ribosom', 'Kloroplas'],
          correct: 3,
          reasons: [
            'Salah. Mitokondria adalah tempat respirasi sel, yaitu mengubah glukosa menjadi energi. Ini berlawanan arah dengan fotosintesis yang justru membentuk glukosa.',
            'Salah. Inti sel mengatur kegiatan sel dan menyimpan materi genetik (DNA). Inti sel tidak mengandung klorofil sehingga tidak bisa menangkap cahaya.',
            'Salah. Ribosom adalah tempat pembuatan protein. Ribosom tidak punya klorofil dan tidak terlibat langsung dalam fotosintesis.',
            'Benar. Kloroplas adalah organel yang mengandung klorofil. Di dalamnya cahaya ditangkap dan diubah menjadi energi kimia pada glukosa, sehingga di sinilah fotosintesis berlangsung.',
          ],
        ),
        (
          question: 'Apa sumber energi utama fotosintesis?',
          options: ['Panas bumi', 'Air hujan', 'Cahaya matahari', 'Angin'],
          correct: 2,
          reasons: [
            'Salah. Panas bumi berasal dari dalam bumi dan bukan berupa cahaya, sehingga tidak bisa ditangkap oleh klorofil.',
            'Salah. Air hujan menambah air di tanah yang dipakai sebagai bahan baku, tetapi air bukan sumber energi. Fotosintesis tetap butuh energi dari luar.',
            'Benar. Energi cahaya matahari ditangkap klorofil lalu diubah menjadi energi kimia yang tersimpan di dalam glukosa. Itulah sebabnya fotosintesis hanya berjalan optimal saat ada cahaya.',
            'Salah. Angin membantu penyerbukan dan penyebaran biji, tetapi tidak menyediakan energi cahaya yang dibutuhkan fotosintesis.',
          ],
        ),
    ],
    // Biologi - Modul 2 (Fotosintesis: mudah)
    102: [
        (
          question: 'Tumbuhan hijau bisa membuat makanannya sendiri. Makhluk hidup seperti ini disebut?',
          options: ['Heterotrof', 'Autotrof', 'Parasit', 'Pengurai'],
          correct: 1,
          reasons: [
            'Salah. Heterotrof adalah makhluk hidup yang tidak bisa membuat makanan sendiri dan harus makan makhluk lain, seperti hewan dan manusia. Tumbuhan hijau justru bisa membuat makanan sendiri.',
            'Benar. Autotrof adalah makhluk hidup yang membuat makanannya sendiri. Tumbuhan hijau melakukannya lewat fotosintesis, memakai cahaya matahari, air, dan karbon dioksida.',
            'Salah. Parasit hidup menumpang pada makhluk lain dan mengambil makanan dari inangnya. Tumbuhan hijau biasa tidak hidup dengan cara itu.',
            'Salah. Pengurai, seperti jamur dan bakteri, mendapat makanan dengan menguraikan sisa makhluk hidup yang sudah mati. Mereka tidak melakukan fotosintesis.',
          ],
        ),
        (
          question: 'Bagian tumbuhan yang paling banyak melakukan fotosintesis adalah?',
          options: ['Akar', 'Daun', 'Batang', 'Bunga'],
          correct: 1,
          reasons: [
            'Salah. Akar berada di dalam tanah dan tidak terkena cahaya matahari. Tugas akar adalah menyerap air dan mineral, bukan fotosintesis.',
            'Benar. Daun berwarna hijau karena banyak mengandung klorofil, lebar sehingga mudah menangkap cahaya, dan punya stomata untuk keluar masuknya gas. Karena itu daun disebut tempat utama fotosintesis.',
            'Salah. Batang berfungsi menopang tumbuhan dan mengangkut air serta zat makanan. Pada beberapa tumbuhan batang muda memang hijau, tetapi fotosintesis utama tetap terjadi di daun.',
            'Salah. Bunga berfungsi untuk perkembangbiakan, misalnya membentuk buah dan biji. Bunga bukan tempat utama fotosintesis.',
          ],
        ),
        (
          question: 'Gas apa yang dilepaskan tumbuhan ke udara saat fotosintesis?',
          options: ['Karbon dioksida', 'Nitrogen', 'Oksigen', 'Uap bensin'],
          correct: 2,
          reasons: [
            'Salah. Karbon dioksida justru diserap tumbuhan dari udara sebagai bahan baku fotosintesis, bukan dilepaskan.',
            'Salah. Nitrogen bukan hasil fotosintesis. Tumbuhan tidak melepaskan nitrogen saat membuat makanan.',
            'Benar. Oksigen adalah gas buangan dari fotosintesis. Gas ini dilepas ke udara dan dipakai manusia serta hewan untuk bernapas. Itulah sebabnya tumbuhan penting bagi kehidupan.',
            'Salah. Uap bensin berasal dari bahan bakar kendaraan, bukan dari tumbuhan, dan tidak dihasilkan fotosintesis.',
          ],
        ),
        (
          question: 'Fotosintesis paling aktif berlangsung pada waktu?',
          options: [
            'Siang hari saat ada cahaya',
            'Tengah malam',
            'Hanya ketika hujan',
            'Ketika tanah kering',
          ],
          correct: 0,
          reasons: [
            'Benar. Fotosintesis membutuhkan cahaya matahari sebagai sumber energi. Karena cahaya paling banyak tersedia di siang hari, fotosintesis paling aktif pada saat itu.',
            'Salah. Pada malam hari tidak ada cahaya matahari, sehingga fotosintesis hampir berhenti. Tanpa energi cahaya, tumbuhan tidak bisa membuat glukosa.',
            'Salah. Hujan menambah air, tetapi saat hujan langit biasanya mendung sehingga cahaya berkurang. Yang menentukan fotosintesis adalah adanya cahaya, bukan hujan.',
            'Salah. Tanah yang kering berarti tumbuhan kekurangan air, salah satu bahan baku fotosintesis. Kondisi ini justru menghambat fotosintesis.',
          ],
        ),
        (
          question: 'Bahan baku fotosintesis yang diserap tumbuhan dari tanah lewat akar adalah?',
          options: ['Air', 'Oksigen', 'Glukosa', 'Cahaya'],
          correct: 0,
          reasons: [
            'Benar. Akar menyerap air dari tanah, lalu air diangkut ke daun. Di daun, air dipakai bersama karbon dioksida dan cahaya untuk membuat glukosa.',
            'Salah. Oksigen adalah hasil fotosintesis yang dilepas ke udara, bukan bahan baku yang diserap akar dari tanah.',
            'Salah. Glukosa adalah hasil fotosintesis, yaitu makanan yang dibuat tumbuhan sendiri. Tumbuhan tidak menyerapnya dari tanah.',
            'Salah. Cahaya berasal dari matahari dan ditangkap oleh daun, bukan diserap akar dari tanah.',
          ],
        ),
    ],
    // Biologi - Modul 3 (Fotosintesis: sedang)
    103: [
        (
          question: 'Pori-pori kecil di permukaan daun tempat keluar masuknya gas disebut?',
          options: ['Xilem', 'Stomata', 'Floem', 'Kutikula'],
          correct: 1,
          reasons: [
            'Salah. Xilem adalah pembuluh yang mengangkut air dan mineral dari akar ke daun. Xilem bukan pori-pori di permukaan daun.',
            'Benar. Stomata adalah pori kecil di epidermis daun yang bisa membuka dan menutup. Lewat stomata, karbon dioksida masuk dan oksigen serta uap air keluar.',
            'Salah. Floem adalah pembuluh yang mengangkut hasil fotosintesis ke seluruh bagian tumbuhan, bukan tempat keluar masuknya gas.',
            'Salah. Kutikula adalah lapisan lilin tipis di permukaan daun yang mengurangi penguapan. Lapisan ini justru menutupi permukaan, bukan pori untuk gas.',
          ],
        ),
        (
          question: 'Pembuluh yang mengangkut air dari akar ke daun adalah?',
          options: ['Floem', 'Stomata', 'Xilem', 'Epidermis'],
          correct: 2,
          reasons: [
            'Salah. Floem mengangkut hasil fotosintesis (glukosa) dari daun ke bagian lain, arahnya berbeda dengan pengangkutan air dari akar.',
            'Salah. Stomata adalah pori di daun untuk pertukaran gas, bukan pembuluh pengangkut.',
            'Benar. Xilem adalah pembuluh kayu yang mengangkut air dan mineral dari akar naik ke batang dan daun. Air ini kemudian dipakai sebagai bahan baku fotosintesis.',
            'Salah. Epidermis adalah lapisan paling luar yang melindungi jaringan di dalamnya. Epidermis bukan pembuluh pengangkut.',
          ],
        ),
        (
          question: 'Pembuluh yang mengangkut hasil fotosintesis ke seluruh tubuh tumbuhan adalah?',
          options: ['Xilem', 'Floem', 'Kambium', 'Empulur'],
          correct: 1,
          reasons: [
            'Salah. Xilem mengangkut air dan mineral dari akar ke atas, bukan mengangkut hasil fotosintesis.',
            'Benar. Floem adalah pembuluh tapis yang membawa glukosa hasil fotosintesis dari daun ke akar, batang, buah, dan bagian lain yang membutuhkan.',
            'Salah. Kambium adalah jaringan yang membelah untuk membuat batang bertambah besar. Kambium bukan pembuluh pengangkut.',
            'Salah. Empulur adalah jaringan di bagian tengah batang yang berfungsi menyimpan cadangan makanan, bukan mengangkutnya.',
          ],
        ),
        (
          question: 'Glukosa hasil fotosintesis yang tidak langsung dipakai akan disimpan dalam bentuk?',
          options: ['Amilum', 'Protein', 'Klorofil', 'Oksigen'],
          correct: 0,
          reasons: [
            'Benar. Kelebihan glukosa diubah menjadi amilum (pati) dan disimpan, misalnya di akar, batang, umbi, atau biji, sebagai cadangan makanan.',
            'Salah. Protein dibuat tumbuhan dengan tambahan unsur seperti nitrogen. Protein bukan bentuk simpanan utama glukosa.',
            'Salah. Klorofil adalah pigmen penangkap cahaya, bukan cadangan makanan.',
            'Salah. Oksigen adalah gas buangan fotosintesis yang dilepas ke udara, bukan zat yang disimpan sebagai cadangan makanan.',
          ],
        ),
        (
          question: 'Daun tumbuhan berwarna hijau karena mengandung?',
          options: ['Karotenoid', 'Klorofil', 'Antosianin', 'Xantofil'],
          correct: 1,
          reasons: [
            'Salah. Karotenoid adalah pigmen kuning sampai oranye, seperti pada wortel. Pigmen ini tidak membuat daun tampak hijau.',
            'Benar. Klorofil menyerap cahaya merah dan biru dan memantulkan cahaya hijau, sehingga daun tampak hijau. Klorofil juga pigmen utama yang dipakai dalam fotosintesis.',
            'Salah. Antosianin adalah pigmen merah, ungu, atau biru, misalnya pada daun bayam merah atau kol ungu.',
            'Salah. Xantofil adalah pigmen kuning yang terlihat jelas ketika klorofil berkurang, misalnya saat daun menguning.',
          ],
        ),
    ],
  };

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

  List<({int id, int subjectId, String title, String content})> _materialsOf(int subjectId) =>
      _materials.where((m) => m.subjectId == subjectId).toList();

  int _moduleCount(int subjectId) => _materialsOf(subjectId).length * _modulesPerMaterial;

  ({int id, int subjectId, String title, String content}) _materialOfModule(int moduleId) {
    final mats = _materialsOf(moduleId ~/ 100);
    return mats[((moduleId % 100) - 1) ~/ _modulesPerMaterial];
  }

  String _subjectPath(int subjectId) {
    final s = _subjects.firstWhere((x) => x.id == subjectId);
    final c = _categories.firstWhere((x) => x.id == s.categoryId);
    return '${c.name}-${s.name}';
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
    final m = _materialOfModule(moduleId);
    final bank = _quizBank[moduleId];
    if (bank != null) {
      return List.generate(bank.length, (i) {
        final b = bank[i];
        return _Q(
          moduleId * 100 + i + 1,
          b.question,
          b.options,
          b.correct,
          b.reasons[b.correct],
          reasons: b.reasons,
        );
      });
    }
    // Modul yang belum diisi: soal DUMMY.
    return List.generate(5, (i) {
      final k = i + 1;
      final correct = (k + moduleId) % 4;
      return _Q(
        moduleId * 100 + k,
        '[DUMMY] Soal $k tentang ${m.title}?',
        const ['Jawaban A', 'Jawaban B', 'Jawaban C', 'Jawaban D'],
        correct,
        '[DUMMY] Pembahasan soal $k. Isi asli dibuat admin di Panel Filament.',
        reasons: [
          for (var j = 0; j < 4; j++)
            j == correct
                ? '[DUMMY] Alasan pilihan ${'ABCD'[j]} benar. Isi asli dibuat admin.'
                : '[DUMMY] Alasan pilihan ${'ABCD'[j]} salah. Isi asli dibuat admin.',
        ],
      );
    });
  }

  @override
  Future<List<QuizModuleModel>> modules(int subjectId) async {
    await _wait();
    final u = _user;
    if (!_subjects.any((s) => s.id == subjectId)) {
      throw ApiException('Bidang tidak ditemukan.');
    }
    return List.generate(_moduleCount(subjectId), (i) {
      final n = i + 1;
      final id = subjectId * 100 + n;
      final best = u.moduleBest[id];
      final prevDone = n == 1 || u.moduleBest.containsKey(id - 1);
      final material = _materialOfModule(id);
      return QuizModuleModel(
        id: id,
        subjectId: subjectId,
        materialId: material.id,
        moduleNumber: n,
        title: material.title,
        status: best != null ? 'completed' : (prevDone ? 'available' : 'locked'),
        bestScore: best,
      );
    });
  }

  @override
  Future<AttemptModel> startAttempt(int moduleId) async {
    await _wait();
    final u = _user;
    final subjectId = moduleId ~/ 100;
    final n = moduleId % 100;
    if (!_subjects.any((s) => s.id == subjectId) || n < 1 || n > _moduleCount(subjectId)) {
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
      chosenExplanation: q.reasons[optionIndex],
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
        subtitle: '${_subjectPath(a.moduleId ~/ 100)} · Modul ${a.moduleId % 100} · $score%',
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
            options: [
              for (var j = 0; j < q.options.length; j++)
                ReviewOptionModel(
                  label: 'ABCD'[j],
                  text: q.options[j],
                  isCorrect: j == q.correct,
                  isChosen: j == chosen,
                  reason: q.reasons[j],
                ),
            ],
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