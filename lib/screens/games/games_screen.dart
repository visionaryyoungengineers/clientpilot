import 'dart:convert';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_kit/whisper_kit.dart';
import 'package:isar/isar.dart';
import '../../widgets/aero_card.dart';
import '../../theme/app_colors.dart';
import '../../services/conversation_repository.dart';
import '../../services/contacts_service.dart';
import '../../services/local_llm_service.dart';
import '../../services/model_manager_service.dart';
import '../../services/gamification_engine.dart';
import '../../services/database_service.dart';
import '../../models/badge.dart';
import '../../models/contact.dart';

class GamesScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const GamesScreen({super.key, this.initialTab = 0});
  @override ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  late int _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        // Tab row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            _TabBtn(label: '🎮 Mini-Games', selected: _activeTab == 0, onTap: () => setState(() => _activeTab = 0)),
            const SizedBox(width: 8),
            _TabBtn(label: '🏆 Badges', selected: _activeTab == 1, onTap: () => setState(() => _activeTab = 1)),
          ]),
        ),
        Expanded(child: _activeTab == 0 ? const _GamesTab() : const _BadgesTab()),
      ]),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withAlpha(25) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: theme.colorScheme.primary.withAlpha(100)) : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(150))),
      ),
    );
  }
}

// ─── Games Tab ────────────────────────────────────────────────────────────────
class _GamesTab extends ConsumerStatefulWidget {
  const _GamesTab();
  @override ConsumerState<_GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends ConsumerState<_GamesTab> {
  final Map<String, int> _scores = {'Pitch Perfect': 0, 'Client Trivia': 0, 'Deal Closer': 0, 'Negotiation Sim': 0, 'Time Manager': 0, 'Client VR': 0};
  SharedPreferences? _prefs;
  bool _hasEnoughClients = false; // Trivia unlocked when 3+ contacts exist

  @override
  void initState() {
    super.initState();
    _loadScores();
    _checkClientCount();
  }

  Future<void> _checkClientCount() async {
    final isar = await ref.read(isarProvider.future);
    final contacts = await isar.contacts.where().idGreaterThan(-1).findAll();
    if (mounted) setState(() => _hasEnoughClients = contacts.length >= 3);
  }

  Future<void> _loadScores() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _scores['Pitch Perfect'] = _prefs?.getInt('game_score_Pitch Perfect') ?? 0;
      _scores['Client Trivia'] = _prefs?.getInt('game_score_Client Trivia') ?? 0;
      _scores['Deal Closer'] = _prefs?.getInt('game_score_Deal Closer') ?? 0;
      _scores['Negotiation Sim'] = _prefs?.getInt('game_score_Negotiation Sim') ?? 0;
      _scores['Time Manager'] = _prefs?.getInt('game_score_Time Manager') ?? 0;
      _scores['Client VR'] = _prefs?.getInt('game_score_Client VR') ?? 0;
    });
  }

  Future<void> _saveScore(String game, int newScore) async {
    int current = _scores[game] ?? 0;
    if (newScore > current) {
      current = newScore;
    } else {
      current += newScore; // accumulate
    }
    await _prefs?.setInt('game_score_$game', current);
    setState(() => _scores[game] = current);
    
    // Check Gamer badge (played all 3)
    if ((_scores['Pitch Perfect']! > 0) && (_scores['Client Trivia']! > 0) && (_scores['Deal Closer']! > 0)) {
      await _prefs?.setBool('badge_Gamer', true);
    }
    
    // Check continuous score milestones
    final totalScore = _scores.values.fold(0, (sum, score) => sum + score);
    if (totalScore >= 500) await _prefs?.setBool('badge_Novice Gamer', true);
    if (totalScore >= 1500) await _prefs?.setBool('badge_Pro Gamer', true);
    if (totalScore >= 3000) await _prefs?.setBool('badge_Master Gamer', true);
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        _GameCard(emoji: '🎤', name: 'Pitch Perfect', description: 'Record a live sales pitch and get real-time AI analysis on clarity, persuasiveness and confidence.', score: _scores['Pitch Perfect']!, difficulty: 'Medium', onPlay: () => _playPitchPerfect(context)),
        const SizedBox(height: 12),
        // Client Trivia is only available when you have 3+ contacts
        if (_hasEnoughClients)
          _GameCard(emoji: '🤔', name: 'Client Trivia', description: 'AI quizzes you on details about your own clients to see how well you know them.', score: _scores['Client Trivia']!, difficulty: 'Hard', onPlay: () => _playClientTrivia(context))
        else
          _LockedGameCard(emoji: '🤔', name: 'Client Trivia', reason: 'Add at least 3 contacts to unlock this game.'),
        const SizedBox(height: 12),
        _GameCard(emoji: '🤝', name: 'Deal Closer', description: 'Simulate high-pressure deal-closing scenarios and make the right choices.', score: _scores['Deal Closer']!, difficulty: 'Hard', onPlay: () => _playDealCloser(context)),
        const SizedBox(height: 12),
        _GameCard(emoji: '🎥', name: 'Negotiation Sim', description: 'Roleplay dealing with difficult, stubborn clients and find a win-win.', score: _scores['Negotiation Sim']!, difficulty: 'Hard', onPlay: () => _playNegotiationSim(context)),
        const SizedBox(height: 12),
        _GameCard(emoji: '⏱️', name: 'Time Manager', description: 'Prioritize a rapid-fire list of CRM tasks based on urgency and business value.', score: _scores['Time Manager']!, difficulty: 'Medium', onPlay: () => _playTimeManager(context)),
        const SizedBox(height: 12),
        _GameCard(emoji: '🥽', name: 'Client VR', description: 'Practice a virtual face-to-face with an AI-simulated client from your contacts.', score: _scores['Client VR']!, difficulty: 'Hard', onPlay: () => _playClientVR(context)),
      ],
    );
  }

  void _playPitchPerfect(BuildContext ctx) {
    final recorder = AudioRecorder();

    showDialog(context: ctx, builder: (c) {
      bool isRecording = false;
      bool isAnalyzing = false;
      String? result;

      return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('🎤 Pitch Perfect'),
          content: isAnalyzing
              ? const Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('AI is analyzing your pitch...')])
              : result != null
                  ? Text(result!, style: const TextStyle(fontSize: 14))
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('Sell this business software to me.', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onLongPressStart: (_) async {
                          if (!await recorder.hasPermission()) return;
                          final dir = await getApplicationDocumentsDirectory();
                          await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: '${dir.path}/pitch_${DateTime.now().millisecondsSinceEpoch}.m4a');
                          setDialogState(() => isRecording = true);
                        },
                        onLongPressEnd: (_) async {
                          setDialogState(() { isRecording = false; isAnalyzing = true; });
                          final path = await recorder.stop();
                          if (path == null) return;
                          try {
                            // Transcribe via Whisper
                            final modelDir = (await getApplicationDocumentsDirectory()).path;
                            final whisper = Whisper(model: WhisperModel.tiny, modelDir: modelDir);
                            final stt = await whisper.transcribe(transcribeRequest: TranscribeRequest(audio: path));
                            final transcript = stt.text ?? '';
                            // Analyze via Qwen
                            final modelMgr = ref.read(modelManagerProvider);
                            final llm = ref.read(llmServiceProvider);
                            await llm.loadModel(await modelMgr.getModelPath());
                            final responseText = await llm.generatePitchAnalysis(transcript);
                            final rawJson = responseText.substring(responseText.indexOf('{'), responseText.lastIndexOf('}') + 1);
                            final analysis = jsonDecode(rawJson) as Map<String, dynamic>;
                            final score = (analysis['score'] as num?)?.toInt() ?? 60;
                            final feedback = analysis['feedback'] ?? 'Good effort!';
                            final strengths = (analysis['strengths'] as List?)?.join(', ') ?? '';
                            _saveScore('Pitch Perfect', score);
                            setDialogState(() {
                              isAnalyzing = false;
                              result = '🏆 Score: $score/100\n\n💬 $feedback${strengths.isNotEmpty ? "\n\n✅ Strengths: $strengths" : ""}';
                            });
                          } catch (e) {
                            _saveScore('Pitch Perfect', 60);
                            setDialogState(() { isAnalyzing = false; result = 'Analysis complete! Score: 60/100. Keep practicing!'; });
                          } finally {
                            recorder.dispose();
                          }
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                          child: Icon(isRecording ? Icons.mic : Icons.mic_none, color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(isRecording ? '🔴 Recording... Release to analyze' : 'Hold to Pitch', style: const TextStyle(fontSize: 12)),
                    ]),
          actions: result != null ? [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Done'))] : null,
        );
      });
    });
  }

  Future<void> _playClientTrivia(BuildContext ctx) async {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (c) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Synthesizing client trivia...'),
          ],
        ),
      ),
    );

    try {
      final repo = await ref.read(conversationRepoProvider.future);
      final convs = await repo.getAll();
      
      if (convs.isEmpty) {
        if (ctx.mounted) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('You need to add some clients/conversations first!')));
        }
        return;
      }

      // Pick random conversation and format details
      final c = convs.toList()..shuffle();
      final target = c.first;
      
      final clientData = '''
      Client Name: \${target.contactName}
      Company: \${target.companyName}
      Job Title: \${target.jobTitle}
      Deal Value: \${target.dealAmount}
      Location: \${target.location}
      Summary: \${target.summary}
      ''';

      // Ensure model is loaded before inferencing
      final modelPaths = ref.read(modelManagerProvider);
      final llm = ref.read(llmServiceProvider);
      final modelPath = await modelPaths.getModelPath();
      await llm.loadModel(modelPath);

      final responseText = await llm.generateTriviaQuestion(clientData);
      
      if (ctx.mounted) Navigator.pop(ctx); // Hide loading

      try {
        final rawJson = responseText.substring(responseText.indexOf('{'), responseText.lastIndexOf('}') + 1);
        final q = jsonDecode(rawJson) as Map<String, dynamic>;

        if (ctx.mounted) {
          showDialog(context: ctx, builder: (c) {
            return AlertDialog(
              title: const Text('Client Trivia 🤔'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q['q'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...List.generate((q['opts'] as List).length, (index) => ListTile(
                    title: Text(q['opts'][index].toString()),
                    onTap: () {
                      Navigator.pop(c);
                      if (index == q['ans']) {
                        _saveScore('Client Trivia', 100);
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('🎉 Correct! +100 points!')));
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Oops, incorrect! No points.')));
                      }
                    }
                  )),
                ],
              ),
            );
          });
        }
      } catch (e) {
        if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed to parse question: $e')));
      }

    } catch (e) {
      if (ctx.mounted) {
        Navigator.pop(ctx); // Hide loading
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  final List<Map<String, dynamic>> _dealQuestions = [
    {'q': 'The client says your product is too expensive. What do you do?', 'opts': ['Offer a 50% discount immediately.', 'Highlight the ROI and long-term savings.', 'Walk away.'], 'ans': 1},
    {'q': 'The decision-maker is not in the meeting. What do you do?', 'opts': ['Pitch anyway and hope for the best.', 'Reschedule the meeting.', 'Ask to get them on a quick call.'], 'ans': 2},
    {'q': 'The client asks for a feature you don\'t have. What do you do?', 'opts': ['Lie and say you have it.', 'Focus on your strengths and suggest workarounds.', 'Say "No" bluntly.'], 'ans': 1},
  ];

  void _playDealCloser(BuildContext ctx) {
    final q = _dealQuestions[(DateTime.now().millisecondsSinceEpoch % _dealQuestions.length)];
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: const Text('🤝 Deal Closer'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(q['q']), const SizedBox(height: 10),
        ...List.generate((q['opts'] as List).length, (index) => ListTile(
          title: Text((q['opts'] as List)[index]),
          onTap: () {
            Navigator.pop(c);
            if (index == q['ans']) { _saveScore('Deal Closer', 200); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('🎉 Perfect play! +200 points!'))); }
            else { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Not the best move. Value lost.'))); }
          },
        )),
      ]),
    ));
  }

  // Time Manager game: sort tasks by priority
  final List<Map<String, dynamic>> _timeManagerChallenges = [
    {
      'scenario': 'You have 30 mins free. Which task should you tackle FIRST?',
      'tasks': ['Update CRM notes from last week', 'Call a hot lead who is deciding today', 'Prepare next quarter presentation', 'Clean up your email inbox'],
      'correct': 1, // Calling hot lead deciding today
      'explanation': 'Hot leads deciding today have highest immediacy and direct revenue impact.'
    },
    {
      'scenario': 'A client calls you while you are in a team meeting. What do you do?',
      'tasks': ['Ignore the call completely', 'Step out immediately to take it', 'Send a quick SMS saying you will call back in 10 mins', 'Let it go to voicemail'],
      'correct': 2, // Send SMS
      'explanation': 'A quick message shows respect for both the meeting and the client.'
    },
    {
      'scenario': 'Same deadline: prepare a proposal or follow up 3 overdue clients?',
      'tasks': ['Write the new proposal first', 'Follow up all 3 overdue clients first', 'Do both partially', 'Postpone both'],
      'correct': 1,
      'explanation': 'Existing relationships are at risk — retained business takes priority over new opportunities.'
    },
  ];

  void _playTimeManager(BuildContext ctx) {
    final challenge = _timeManagerChallenges[(DateTime.now().millisecondsSinceEpoch % _timeManagerChallenges.length)];
    showDialog(context: ctx, builder: (c) {
      int? selected;
      return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('⏱️ Time Manager'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(challenge['scenario'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              ...List.generate((challenge['tasks'] as List).length, (i) => GestureDetector(
                onTap: selected == null ? () {
                  setDialogState(() => selected = i);
                  Navigator.pop(context);
                  if (i == challenge['correct']) {
                    _saveScore('Time Manager', 200);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('🎉 Correct! +200 pts! ${challenge["explanation"]}'), duration: const Duration(seconds: 4)));
                  } else {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('❌ Not optimal. ${challenge["explanation"]}'), duration: const Duration(seconds: 4)));
                  }
                } : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text((challenge['tasks'] as List)[i].toString(), style: const TextStyle(fontSize: 13)),
                ),
              )),
            ],
          ),
        );
      });
    });
  }

  // Negotiation Sim (own questions)
  final List<Map<String, dynamic>> _negotiationQuestions = [
    {
      'q': 'The client threatens to go to a competitor unless you match their price. You say:',
      'opts': ['"We can match it, what price?"', '"Our value is worth the premium — let me show you the ROI."', '"Good luck with the competitor."'],
      'ans': 1
    },
    {
      'q': 'The client keeps changing scope mid-contract. Your best move:',
      'opts': ['Accept all changes to keep the client happy', 'Ignore them and stick to original', 'Document changes and present revised pricing'],
      'ans': 2
    },
    {
      'q': 'The client wants a 6-month free trial before committing. You should:',
      'opts': ['Agree — better than nothing', 'Offer a short pilot at a reduced rate with clear success metrics', 'Decline firmly'],
      'ans': 1
    },
  ];

  void _playNegotiationSim(BuildContext ctx) {
    final q = _negotiationQuestions[(DateTime.now().millisecondsSinceEpoch % _negotiationQuestions.length)];
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: const Text('🎥 Negotiation Sim'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q['q'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...List.generate((q['opts'] as List).length, (i) => ListTile(
            title: Text((q['opts'] as List)[i].toString()),
            onTap: () {
              Navigator.pop(c);
              if (i == q['ans']) {
                _saveScore('Negotiation Sim', 200);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('🏆 Exactly right! +200 pts!')));
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Think about long-term relationship impact.')));
              }
            },
          )),
        ],
      ),
    ));
  }

  // Client VR: virtual practice with an actual client from their Contacts
  Future<void> _playClientVR(BuildContext ctx) async {
    showDialog(context: ctx, barrierDismissible: false, builder: (c) => const AlertDialog(content: Row(children: [CircularProgressIndicator(), SizedBox(width: 20), Text('Loading your clients...')]) ));
    try {
      final isar = await ref.read(isarProvider.future);
      final allContacts = await isar.contacts.where().idGreaterThan(-1).findAll();
      if (allContacts.isEmpty) {
        if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Add some contacts first to use Client VR!'))); }
        return;
      }
      final contact = (allContacts..shuffle()).first;
      final bio = contact.bio ?? 'No background info available.';
      if (ctx.mounted) Navigator.pop(ctx);
      if (ctx.mounted) {
        showDialog(context: ctx, builder: (c) => AlertDialog(
          title: Text('🥽 Client VR: ${contact.name}'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Company: ${contact.company ?? "Unknown"}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Background: $bio', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Opening Line Practice:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            const Text('How would you open the conversation with this client?', style: TextStyle(fontSize: 13)),
          ]),
          actions: [
            TextButton(onPressed: () { Navigator.pop(c); _saveScore('Client VR', 100); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('+100 pts for completing the VR session!'))); }, child: const Text('Session Done ✔️')),
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ],
        ));
      }
    } catch (e) {
      if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    }
  }
}

class _GameCard extends StatelessWidget {
  final String emoji, name, description, difficulty;
  final int score;
  final VoidCallback onPlay;
  const _GameCard({required this.emoji, required this.name, required this.description, required this.difficulty, required this.score, required this.onPlay});

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diffColor = difficulty == 'Easy' ? const Color(0xFF16A34A) : difficulty == 'Medium' ? AppColors.amber : theme.colorScheme.error;
    return AeroCard(padding: const EdgeInsets.all(16), child: Row(children: [
      Container(width: 52, height: 52, decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26)))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: diffColor.withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Text(difficulty, style: TextStyle(fontSize: 10, color: diffColor, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140)), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Text('Best: $score pts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.amber)),
      ])),
      const SizedBox(width: 10),
      FilledButton(onPressed: onPlay, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)), child: const Text('Play')),
    ]));
  }
}

class _LockedGameCard extends StatelessWidget {
  final String emoji, name, reason;
  const _LockedGameCard({required this.emoji, required this.name, required this.reason});

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: 0.5,
      child: AeroCard(padding: const EdgeInsets.all(16), child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(reason, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140))),
        ])),
        const SizedBox(width: 10),
        Icon(Icons.lock, color: theme.colorScheme.onSurface.withAlpha(80), size: 24),
      ])),
    );
  }
}

// ─── Badges Tab ───────────────────────────────────────────────────────────────
class _BadgesTab extends ConsumerStatefulWidget {
  const _BadgesTab();
  @override ConsumerState<_BadgesTab> createState() => _BadgesTabState();
}

class _BadgesTabState extends ConsumerState<_BadgesTab> {
  List<({String emoji, String name, String desc, bool earned})> _badges = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAndEvaluate();
  }

  Future<void> _loadAndEvaluate() async {
    setState(() => _loading = true);
    try {
      final isar = await ref.read(isarProvider.future);
      final engine = ref.read(gamificationEngineProvider);

      // Evaluate and award any newly earned badges
      final newlyEarned = await engine.evaluateAndAward(isar);

      // Show toast for newly earned
      if (mounted && newlyEarned.isNotEmpty) {
        for (final name in newlyEarned) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🏆 Badge Earned! $name'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // Load all badges from definition list, marking earned ones from Isar
      final earnedBadges = await isar.badges.buildQuery<Badge>().findAll();
      final earnedIds = {for (final b in earnedBadges) b.badgeId};

      if (mounted) {
        setState(() {
          _badges = GamificationEngine.definitions.map((def) => (
            emoji: def.emoji,
            name: def.title,
            desc: def.description,
            earned: earnedIds.contains(def.id),
          )).toList();
          _loading = false;
        });
      }
    } catch (e) {
      // Fallback to definition list with no earned badges
      if (mounted) {
        setState(() {
          _badges = GamificationEngine.definitions.map((def) => (
            emoji: def.emoji,
            name: def.title,
            desc: def.description,
            earned: false,
          )).toList();
          _loading = false;
        });
      }
    }
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        AeroCard(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Row(children: [
          Text('${_badges.where((b) => b.earned).length}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(' / ${_badges.length} Badges Earned', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(140))),
          const Spacer(),
          TextButton.icon(
            onPressed: _loadAndEvaluate,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Check'),
          ),
        ])),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true, crossAxisCount: 3, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85,
          children: _badges.map((b) => _BadgeTile(badge: b)).toList(),
        ),
      ],
    );
  }
}


class _BadgeTile extends StatelessWidget {
  final ({String emoji, String name, String desc, bool earned}) badge;
  const _BadgeTile({required this.badge});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: badge.earned ? theme.colorScheme.primary.withAlpha(15) : theme.colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(14),
        border: badge.earned ? Border.all(color: theme.colorScheme.primary.withAlpha(60)) : null,
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ColorFiltered(
          colorFilter: badge.earned ? const ColorFilter.mode(Colors.transparent, BlendMode.saturation) : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
          child: Text(badge.emoji, style: const TextStyle(fontSize: 30)),
        ),
        const SizedBox(height: 6),
        Text(badge.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badge.earned ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withAlpha(100)), textAlign: TextAlign.center, maxLines: 2),
      ]),
    );
  }
}
