import '../models/tutor_context.dart';
import 'package:growly_core/growly_core.dart';

class PromptTemplates {
  String buildSystemPrompt(PromptContext context) {
    final ageGroup = context.childContext.ageGroup;

    final basePrompt = '''
Kamu adalah AI tutor bernama "Growly" untuk anak-anak Indonesia berusia ${context.childContext.age} tahun.
Kamu berbicara dalam Bahasa Indonesia yang sederhana dan ramah.
''';

    final ageSpecificPrompt = _getAgeGroupPrompt(ageGroup);
    final modePrompt = _getModePrompt(context.mode);
    final safetyPrompt = _getSafetyPrompt(ageGroup);

    return '$basePrompt\n\n$ageSpecificPrompt\n\n$modePrompt\n\n$safetyPrompt';
  }

  String _getAgeGroupPrompt(AgeGroup ageGroup) {
    switch (ageGroup) {
      case AgeGroup.earlyChildhood:
        return '''
- Gunakan kalimat sangat pendek (2-4 kata per kalimat)
- Gunakan banyak emoji
- Ajukan pertanyaan ya/tidak atau pilihan ganda
- Berikan pujian yang berlebihan untuk setiap effort
- Ceritakan cerita dengan banyak pengulangan
''';
      case AgeGroup.primary:
        return '''
- Gunakan kalimat pendek (5-8 kata per kalimat)
- Berikan penjelasan dengan contoh visual
- Ajukan pertanyaan terbuka yang sederhana
- Berikan semangat dan dorongan
- Ceritakan cerita dengan dialog
''';
      case AgeGroup.upperPrimary:
        return '''
- Gunakan penjelasan yang lebih detail
- Berikan konteks dan alasan
- Ajukan pertanyaan yang mendorong pemikiran kritis
- Berikan tantangan yang sesuai
- Sertakan penjelasan tentang "bagaimana" dan "mengapa"
''';
      case AgeGroup.teen:
        return '''
- Gunakan bahasa yang lebih formal tapi tetap ramah
- Berikan penjelasan mendalam
- Dorong pemikiran mandiri dan analisis
- Berikan umpan balik yang konstruktif
- Treated seperti teman yang lebih tua
''';
    }
  }

  String _getModePrompt(String mode) {
    switch (mode.toLowerCase()) {
      case 'story':
        return '''
- Kamu adalah storyteller yang membuat cerita interaktif
- Selalu akhiri dengan pertanyaan comprehension
- Gunakan descriptive language yang sesuai usia
- Jika anak menjawab, berikan respons positif dan lanjutkan cerita
''';
      case 'math':
        return '''
- Kamu adalah math buddy yang mengajarkan konsep matematika
- gunakan pendekatan "show, don't tell" - biarkan anak menemukan jawabannya
- Berikan hint terlebih dahulu, bukan jawaban langsung
- gunakan visual/metaphor untuk menjelaskan konsep
- Rayakan setiap keberhasilan kecil
''';
      case 'homework':
        return '''
- Kamu adalah homework guide yang membantu memahami konsep
- JANGAN langsung berikan jawaban
- Ajukan pertanyaan Socratic untuk memandu pemikiran
- Pecah masalah menjadi langkah-langkah kecil
- Berikan contoh analogi dari kehidupan sehari-hari
''';
      case 'hint':
        return '''
- Kamu memberikan hint, BUKAN jawaban
- Mulai dengan hint yang sangat umum
- Semakin banyak pertanyaan, semakin spesifik hintnya
- Arahkan anak ke pemahaman, bukan hafalan
''';
      default:
        return '''
- Bersikap ramah dan suportif
- Selalu positif dalam feedback
- Dorong anak untuk mencoba lagi
''';
    }
  }

  String _getSafetyPrompt(AgeGroup ageGroup) {
    return '''
KEAMANAN:
- JANGAN pernah membahas konten dewasa, kekerasan, atau topik sensitif
- JANGAN pernah meminta informasi pribadi (nama lengkap, alamat, sekolah)
- JANGAN pernah membandingkan anak dengan anak lain
- Jika anak bertanya tentang topik tidak pantas, alihkan dengan: "Wah, itu topik yang lebih baik ditanyakan orang tua ya!"
- Jika anak terlihat kesal atau frustrasi, ambil jeda dan tenangkan

BATASAN:
- Jawab hanya pertanyaan tentang pembelajaran dan topik positif
- Untuk topik di luar pembelajaran, arahkan ke: "Hmm, itu menarik! Tapi Growly lebih suka membantu belajar. Mau belajar apa hari ini?"
''';
  }

  String buildUserPrompt(String question, TutorContext context) {
    final name = context.name ?? 'Anak';
    return 'Anak ($name, ${context.age} tahun) bertanya: "$question"';
  }

  String buildStoryPrompt({
    required TutorContext context,
    required String topic,
    String? startingPoint,
  }) {
    final ageGroup = context.ageGroup;
    final length = ageGroup == AgeGroup.earlyChildhood ? 'pendek' : 'sedang';
    final name = context.name ?? 'Andi';

    final prompt = StringBuffer();
    prompt.write('Buatkan cerita pendek (panjang $length) tentang "$topic" ');
    if (startingPoint != null) {
      prompt.write('yang dimulai dengan: "$startingPoint" ');
    }
    prompt.write('untuk anak berusia ${context.age} tahun bernama $name. ');
    prompt.write('Cerita harus:');
    prompt.write('\n1. Menggunakan bahasa Indonesia sederhana');
    prompt.write('\n2. Memiliki karakter yang relatable');
    prompt.write('\n3. Mengajarkan satu nilai/moral yang jelas');
    prompt.write('\n4. Diakhiri dengan pertanyaan comprehension 2-3 pilihan');

    return prompt.toString();
  }

  String buildMathPrompt({
    required TutorContext context,
    required String difficulty,
    String? topic,
  }) {
    final topicText = topic ?? _getDefaultMathTopic(context.ageGroup);
    final difficultyLevel = _mapDifficulty(difficulty);

    return '''
Buatkan soal matematika tentang "$topicText" dengan tingkat kesulitan "$difficultyLevel" untuk anak berusia ${context.age} tahun.
Soal harus:
1. Menggunakan angka yang sesuai kemampuan
2. Menggunakan bahasa Indonesia sederhana
3. Dalam format cerita pendek/kehidupan sehari-hari
4. Memiliki satu jawaban yang jelas
5. Sertakan 3-4 pilihan jawaban

Jangan langsung berikan jawaban - biarkan anak berpikir sendiri.
''';
  }

  String _getDefaultMathTopic(AgeGroup ageGroup) {
    switch (ageGroup) {
      case AgeGroup.earlyChildhood:
        return 'mengenal angka 1-10 dan penjumlahan sederhana';
      case AgeGroup.primary:
        return 'penjumlahan dan pengurangan dua digit';
      case AgeGroup.upperPrimary:
        return 'perkalian dan pembagian';
      case AgeGroup.teen:
        return 'persamaan linear sederhana';
    }
  }

  String _mapDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'mudah':
        return 'pemula';
      case 'medium':
      case 'sedang':
        return 'menengah';
      case 'hard':
      case 'sulit':
        return 'lanjutan';
      default:
        return 'menengah';
    }
  }

  String buildHintPrompt({
    required TutorContext context,
    required String question,
    int hintLevel = 1,
  }) {
    final hintText = _getHintAtLevel(hintLevel);

    return '''
Anak bertanya: "$question"

Untuk menjawab ini, anak perlu memahami konsep berikut (TIDAK KATAKAN KE ANAK):
[CONCEPT PLACEHOLDER - ini akan diisi dengan konsep yang relevan]

Berikan hint ke-$hintLevel:
$hintText

Hint harus membimbing anak ke jawaban, bukan memberikan jawaban langsung.
Gunakan bahasa yang sesuai untuk anak berusia ${context.age} tahun.
''';
  }

  String _getHintAtLevel(int level) {
    switch (level) {
      case 1:
        return 'Hint umum: coba pikirkan kembali konsep dasarnya.';
      case 2:
        return 'Hint sedang: ingat kembali apa yang sudah dipelajari tentang topik ini.';
      case 3:
        return 'Hint spesifik: coba jawab bagian yang lebih kecil dulu.';
      case 4:
        return 'Hint hampir jawaban: hampir sampai, coba lagi dengan cara berbeda.';
      case 5:
        return 'Penjelasan: ini adalah tentang...';
      default:
        return 'Coba pikirkan lagi dari awal.';
    }
  }
}