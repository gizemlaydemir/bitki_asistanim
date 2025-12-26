import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/plant_database.dart';
import '../theme/app_colors.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  bool _loading = true;
  int _donationCount = 0;

  DateTime? _lastVisitTime;
  bool _usedVisitRight = false;

  Timer? _ticker;

  bool get _isTr =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'tr';

  bool get _canAddNow {
    if (_lastVisitTime == null) return false;
    if (_usedVisitRight) return false;
    return DateTime.now().difference(_lastVisitTime!).inSeconds >= 120;
  }

  String get _cooldownText {
    if (_lastVisitTime == null) {
      return _isTr
          ? 'Fidan eklemek için önce bağış sitesine gitmelisin.'
          : 'Go to the donation website first.';
    }

    if (_usedVisitRight) {
      return _isTr
          ? 'Yeni fidan eklemek için tekrar bağış sitesine gitmelisin.'
          : 'To add a new sapling, go to the donation website again.';
    }

    final passed = DateTime.now().difference(_lastVisitTime!).inSeconds;
    final left = 120 - passed;

    if (left <= 0) {
      return _isTr
          ? 'Artık 1 fidan ekleyebilirsin ✅'
          : 'You can add 1 sapling now ✅';
    }

    final m = left ~/ 60;
    final s = (left % 60).toString().padLeft(2, '0');
    return _isTr ? 'Lütfen bekle: $m:$s' : 'Please wait: $m:$s';
  }

  @override
  void initState() {
    super.initState();
    _loadDonationCount();

    // ✅ Arkada geri sayım aksın diye her saniye yenile
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadDonationCount() async {
    final count = await PlantDatabase.instance.getDonationCount();
    if (!mounted) return;
    setState(() {
      _donationCount = count;
      _loading = false;
    });
  }

  Future<void> _addDonation() async {
    if (!_canAddNow) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cooldownText),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final newCount = await PlantDatabase.instance.incrementDonation();
    if (!mounted) return;

    setState(() {
      _donationCount = newCount;
      _usedVisitRight = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isTr
              ? 'Harika! 1 fidan daha ekledin 🌳'
              : 'Great! You added 1 more sapling 🌳',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String get _badgeTitle {
    if (_donationCount == 0) return _isTr ? 'Tohum Aşaması' : 'Seed Stage';
    if (_donationCount < 5) return _isTr ? 'Fidan Dostu' : 'Sapling Friend';
    if (_donationCount < 10) {
      return _isTr ? 'Orman Koruyucusu' : 'Forest Guardian';
    }
    return _isTr ? 'Gezegen Kahramanı' : 'Planet Hero';
  }

  String get _badgeSubtitle {
    if (_donationCount == 0) {
      return _isTr
          ? 'İlk fidanını bağışladığında ilk rozetini kazanacaksın.'
          : 'Donate your first sapling to earn your first badge.';
    } else if (_donationCount < 5) {
      return _isTr
          ? 'Harika gidiyorsun! Biraz daha fidanla sonraki rozete çok yakınsın.'
          : 'You are doing great! A few more saplings to reach the next badge.';
    } else if (_donationCount < 10) {
      return _isTr
          ? 'Sen gerçek bir orman dostusun. Bir üst rozet için az kaldı!'
          : 'You are a real forest friend. Almost at the next badge!';
    } else {
      return _isTr
          ? 'Muhteşemsin! Gezegen için büyük bir fark yaratıyorsun 🌍'
          : 'Amazing! You are making a big difference for the planet 🌍';
    }
  }

  String get _badgeEmoji {
    if (_donationCount == 0) return '🌱';
    if (_donationCount < 5) return '🌿';
    if (_donationCount < 10) return '🌳';
    return '🏆';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (ok && mounted) {
      setState(() {
        _lastVisitTime = DateTime.now();
        _usedVisitRight = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isTr
                ? 'Bağış sitesine yönlendirildin. 2 dakika sonra 1 fidan ekleyebilirsin ⏳'
                : 'You were redirected. You can add 1 sapling after 2 minutes ⏳',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isTr ? 'Bağlantı açılamadı.' : 'Could not open the link.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _isTr ? 'Fidan Bağışı' : 'Sapling Donation';
    final topChipText = _isTr
        ? 'Daha yeşil bir dünya için 🌍'
        : 'For a greener world 🌍';
    final descriptionText = _isTr
        ? 'Sadece evindeki bitkileri değil, doğayı da sulamak ister misin? '
              'Aşağıdaki kurumlar üzerinden fidan bağışı yapabilir, bu sayfada da '
              'kendi bağışladığın fidanları takip edebilirsin.'
        : 'Would you like to support nature, not only your home plants? '
              'You can donate saplings via the organizations below and track '
              'your own donations on this page.';
    final yourSaplingText = _isTr ? 'Senin fidan sayın' : 'Your sapling count';
    final addSaplingText = _isTr ? '1 fidan ekle' : 'Add 1 sapling';
    final orgsTitle = _isTr ? 'Önerilen kurumlar:' : 'Suggested organizations:';
    final footerText = _isTr
        ? 'Bu bölüm yalnızca bilgilendirme amaçlıdır.\nBağış için kurumların resmi web sitelerini kullanmalısın.'
        : 'This section is for informational purposes only.\nPlease use the official websites of the organizations to donate.';

    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        topChipText,
                        style: const TextStyle(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(descriptionText, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 20),

                  // 🔢 Sayaç kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                yourSaplingText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_donationCount 🌱',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _canAddNow ? _addDonation : null,
                          icon: const Icon(Icons.add),
                          label: Text(addSaplingText),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.midGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🎖 Rozet kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.lightGreen.withOpacity(0.9),
                          AppColors.midGreen.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(_badgeEmoji, style: const TextStyle(fontSize: 40)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _badgeTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _badgeSubtitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    orgsTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildOrgCard(
                    title: _isTr ? 'TEMA Vakfı' : 'TEMA Foundation',
                    description: _isTr
                        ? 'Toprakla barışık, erozyonla mücadele ve ağaçlandırma odaklı bağışlar.'
                        : 'Donations focused on erosion control and afforestation.',
                    buttonText: _isTr ? 'Siteye git' : 'Go to website',
                    url: 'https://www.tema.org.tr',
                  ),
                  const SizedBox(height: 12),
                  _buildOrgCard(
                    title: _isTr
                        ? 'OGM / Fidan Bağışı'
                        : 'GDF / Sapling Donation (OGM)',
                    description: _isTr
                        ? 'Orman Genel Müdürlüğü üzerinden hatıra ormanı ve fidan bağışları.'
                        : 'Sapling donations and memorial forests by the General Directorate of Forestry.',
                    buttonText: _isTr ? 'Siteye git' : 'Go to website',
                    url: 'https://www.ogm.gov.tr/bagis',
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      footerText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOrgCard({
    required String title,
    required String description,
    required String buttonText,
    required String url,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.park, color: AppColors.darkGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _openUrl(url),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
