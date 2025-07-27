import 'package:flutter/material.dart';
import '../widgets/senni_preview_widget.dart';

class SenniPreviewScreen extends StatefulWidget {
  const SenniPreviewScreen({Key? key}) : super(key: key);

  @override
  State<SenniPreviewScreen> createState() => _SenniPreviewScreenState();
}

class _SenniPreviewScreenState extends State<SenniPreviewScreen> {
  String _currentMood = 'happy';
  bool _showAnimation = true;
  double _senniSize = 150;

  final List<String> _moods = [
    'happy',
    'excited', 
    'thinking',
    'sad',
    'celebrating',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌸 Senni Preview - Real-time Design'),
        backgroundColor: Colors.pink.shade100,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Preview Area
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SenniPreviewWidget(
                      size: _senniSize,
                      mood: _currentMood,
                      showAnimation: _showAnimation,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Controls
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Animation Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showAnimation = !_showAnimation;
                              });
                            },
                            icon: Icon(_showAnimation ? Icons.pause : Icons.play_arrow),
                            label: Text(_showAnimation ? '⏸️ Pause' : '▶️ Play'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _showAnimation ? Colors.orange : Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentMood = _moods[DateTime.now().millisecond % _moods.length];
                              });
                            },
                            icon: const Icon(Icons.shuffle),
                            label: const Text('🎲 Random'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Size Slider
                      Row(
                        children: [
                          const Text('Size: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Slider(
                              value: _senniSize,
                              min: 100,
                              max: 200,
                              divisions: 10,
                              label: _senniSize.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _senniSize = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Mood Buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _moods.map((mood) {
                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentMood = mood;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentMood == mood 
                                  ? Colors.pink.shade300 
                                  : Colors.grey.shade200,
                              foregroundColor: _currentMood == mood 
                                  ? Colors.white 
                                  : Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Text(_getMoodEmoji(mood)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Mood: $_currentMood',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Size: ${_senniSize.round()}px',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Animation: ${_showAnimation ? "ON" : "OFF"}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '💡 Tip: Thay đổi các thông số để xem Senni real-time!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'happy':
        return '😊 Happy';
      case 'excited':
        return '🎉 Excited';
      case 'thinking':
        return '🤔 Thinking';
      case 'sad':
        return '😢 Sad';
      case 'celebrating':
        return '🌟 Celebrating';
      default:
        return '😊 Happy';
    }
  }
} 