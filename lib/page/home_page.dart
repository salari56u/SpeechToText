import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:country_icons/country_icons.dart';

class VoiceToText extends StatefulWidget {
  const VoiceToText({super.key});

  @override
  State<VoiceToText> createState() => _VoiceToTextState();
}

class _VoiceToTextState extends State<VoiceToText> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordSpoken = "";
  double _confidenceLevel = 0;

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'locale': 'en_US'},
    {'name': 'فارسی', 'locale': 'fa_IR'},
  ];

  String _selectedLanguage = 'en_US';

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: _selectedLanguage,
    );
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Speech To Text"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // دکمه ی مربوط به انتخاب زبان
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: _selectedLanguage,
                items: _languages.map((language) {
                  return DropdownMenuItem<String>(
                    value: language['locale'],
                    child: Row(
                      children: [
                        Image.asset(
                          'icons/flags/png100px/${language['locale'] == 'en_US' ? 'us' : 'ir'}.png',
                          package: 'country_icons',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(language['name']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ),
            //نمایش وضعیت اپ
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? "Listening..."
                    : _speechEnabled
                        ? "Tap the microphone to start listening..."
                        : "Speech not available",
              ),
            ),
            //نمایش متن تشخیص داده شده
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  _wordSpoken,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            //نمایش درصد اطمنیان
            if (_speechToText.isNotListening && _confidenceLevel > 0)
              Text(
                "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
          ],
        ),
      ),
      //دکمه مربوط به شروع و توقف
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        tooltip: "Listen",
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }
}
