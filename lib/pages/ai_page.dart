import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final TextEditingController _plantController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();

  bool _loading = false;
  String? _result;
  String? _error;

  int? _remaining;
  int? _limit;

  Future<void> _getAdvice() async {
    final plantName = _plantController.text.trim();
    final problem = _problemController.text.trim();

    if (problem.isEmpty) {
      setState(() {
        _error = 'Lütfen bir sorun yaz.';
        _result = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      // eski değerleri ekranda tutmak istersen bunları silme, ben temizledim:
      // _remaining = null;
      // _limit = null;
    });

    try {
      final isTr = Localizations.localeOf(context).languageCode == 'tr';

      final resp = await AiService.plantAdvice(
        plantName: plantName.isEmpty ? 'Bitki' : plantName,
        problem: problem,
        isTr: isTr,
        detailed: true, // 🔥 AI kullan
        userId: 'gizem', // 👤 kullanıcı id
      );

      setState(() {
        _result = resp.advice;
        _remaining = resp.remaining;
        _limit = resp.limit;
      });
    } catch (e) {
      final msg = e.toString();

      setState(() {
        // 429 = limit doldu
        if (msg.contains('429') || msg.toLowerCase().contains('limit')) {
          _error = 'Bugünkü AI hakkın doldu 🌿';
        } else {
          _error = 'Hata: $e';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _plantController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    return Scaffold(
      appBar: AppBar(title: Text(isTr ? 'Bitki Asistanı' : 'Plant Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _plantController,
              decoration: InputDecoration(
                labelText: isTr
                    ? 'Bitki adı (isteğe bağlı)'
                    : 'Plant name (optional)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _problemController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isTr ? 'Sorun' : 'Problem',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _getAdvice,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isTr ? 'Öneri al' : 'Get advice'),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Kalan hak göstergesi
            if (_remaining != null && _limit != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isTr
                      ? 'Günlük hak: $_remaining / $_limit'
                      : 'Daily quota: $_remaining / $_limit',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: (_remaining == 0) ? Colors.red : Colors.green,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_result!, style: const TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
