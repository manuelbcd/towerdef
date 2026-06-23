import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'localization/app_localizations.dart';
import 'models/campaign.dart';
import 'models/game_content_index.dart';
import 'progress/campaign_progress.dart';
import 'progress/campaign_progress_repository.dart';
import 'screens/campaign_screen.dart';
import 'screens/game_screen.dart';
import 'screens/stage_briefing_screen.dart';
import 'screens/stage_results_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TowerDefApp());
}

enum CampaignView { campaign, briefing, game, results }

class TowerDefApp extends StatefulWidget {
  final CampaignProgressStore? progressStore;
  final GameContentIndex? content;

  const TowerDefApp({
    super.key,
    this.progressStore,
    this.content,
  });

  @override
  State<TowerDefApp> createState() => _TowerDefAppState();
}

class _TowerDefAppState extends State<TowerDefApp> {
  late final GameContentIndex content;
  late final CampaignProgressRepository progressRepository;
  CampaignProgress? progress;
  CampaignView view = CampaignView.campaign;
  GameSessionConfig? selectedSession;
  GameResult? latestResult;

  @override
  void initState() {
    super.initState();
    content = widget.content ?? gameContentIndex;
    content.validateOrThrow();
    progressRepository = CampaignProgressRepository(
      store: widget.progressStore ?? SharedPreferencesCampaignProgressStore(),
      content: content,
    );
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final loaded = await progressRepository.load();
    if (!mounted) return;
    setState(() => progress = loaded);
  }

  void _openStage(CampaignStageDefinition stage) {
    setState(() {
      selectedSession = content.resolveStage(stage.id);
      view = CampaignView.briefing;
    });
  }

  Future<void> _recordResult(GameResult result) async {
    final currentProgress = progress!;
    final updated = await progressRepository.recordResult(
      progress: currentProgress,
      result: result,
    );
    if (!mounted) return;
    setState(() {
      progress = updated;
      latestResult = result;
      view = CampaignView.results;
    });
  }

  void _continueCampaign() {
    final nextIds = selectedSession!.stage.nextStageIds;
    if (nextIds.isEmpty) {
      _returnToCampaign();
      return;
    }
    _openStage(content.stages[nextIds.first]!);
  }

  void _returnToCampaign() {
    setState(() {
      selectedSession = null;
      latestResult = null;
      view = CampaignView.campaign;
    });
  }

  Widget _buildHome() {
    final currentProgress = progress;
    if (currentProgress == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF10183F),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (view) {
      case CampaignView.campaign:
        return CampaignScreen(
          content: content,
          progress: currentProgress,
          onStageSelected: _openStage,
        );
      case CampaignView.briefing:
        return StageBriefingScreen(
          session: selectedSession!,
          onBack: _returnToCampaign,
          onStart: () => setState(() => view = CampaignView.game),
        );
      case CampaignView.game:
        return GameScreen(
          key: ValueKey(selectedSession!.stage.id),
          session: selectedSession,
          onFinished: _recordResult,
        );
      case CampaignView.results:
        return StageResultsScreen(
          result: latestResult!,
          stage: selectedSession!.stage,
          onCampaign: _returnToCampaign,
          onContinue: latestResult!.victory &&
                  selectedSession!.stage.nextStageIds.isNotEmpty
              ? _continueCampaign
              : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: _buildHome(),
    );
  }
}
