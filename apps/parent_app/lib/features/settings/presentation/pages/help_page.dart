import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HelpSection(
            title: 'Pertanyaan Umum',
            items: const [
              _HelpItem(
                icon: Icons.person_add,
                question: 'Bagaimana cara menambahkan profil anak?',
                answer: 'Pergi ke menu "Anak" di bagian bawah, lalu tekan tombol "+ Tambah Anak". Isi nama, tanggal lahir, dan atur PIN untuk anak Anda.',
              ),
              _HelpItem(
                icon: Icons.lock,
                question: 'Apa itu PIN dan bagaimana cara menggunakannya?',
                answer: 'PIN adalah kode 4-6 digit yang digunakan anak Anda untuk membuka aplikasi Growly. PIN diatur saat membuat profil anak dan bisa diubah oleh orang tua kapan saja.',
              ),
              _HelpItem(
                icon: Icons.access_time,
                question: 'Bagaimana cara mengatur batas waktu layar?',
                answer: 'Pergi ke menu "Kontrol" > pilih anak > "Waktu Layar". Di sana Anda bisa mengatur batas harian dan jadwal istirahat.',
              ),
              _HelpItem(
                icon: Icons.school,
                question: 'Apa itu Mode Sekolah?',
                answer: 'Mode Sekolah memblokir akses ke game dan media sosial selama jam sekolah agar anak bisa fokus belajar.',
              ),
              _HelpItem(
                icon: Icons.star,
                question: 'Bagaimana cara upgrade ke Premium?',
                answer: 'Pergi ke "Pengaturan" > "Langganan" untuk melihat paket Premium dan melakukan upgrade.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _HelpSection(
            title: 'Hubungi Kami',
            items: const [
              _HelpItem(
                icon: Icons.email,
                question: 'Email',
                answer: 'support@growly.id',
              ),
              _HelpItem(
                icon: Icons.chat,
                question: 'Live Chat',
                answer: 'Senin-Jumat, 09.00-17.00 WIB',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, color: cs.primary, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Growly v1.0.0',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI-Powered Digital Growth Platform for Kids',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final List<_HelpItem> items;

  const _HelpSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _HelpCard(item: item)),
      ],
    );
  }
}

class _HelpItem {
  final IconData icon;
  final String question;
  final String answer;

  const _HelpItem({
    required this.icon,
    required this.question,
    required this.answer,
  });
}

class _HelpCard extends StatelessWidget {
  final _HelpItem item;

  const _HelpCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          item.question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            item.answer,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
