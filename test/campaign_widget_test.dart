import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towerdef/localization/app_localizations.dart';
import 'package:towerdef/main.dart';
import 'package:towerdef/models/campaign.dart';
import 'package:towerdef/models/game_content_index.dart';
import 'package:towerdef/progress/campaign_progress.dart';
import 'package:towerdef/progress/campaign_progress_repository.dart';
import 'package:towerdef/screens/campaign_screen.dart';
import 'package:towerdef/screens/stage_briefing_screen.dart';
import 'package:towerdef/screens/stage_results_screen.dart';

void main() {
  testWidgets('Campaign screen opens unlocked stages and blocks locked stages',
      (tester) async {
    CampaignStageDefinition? selected;
    await tester.pumpWidget(_localized(
      CampaignScreen(
        content: gameContentIndex,
        progress: CampaignProgress.initial('green_pass_01'),
        onStageSelected: (stage) => selected = stage,
      ),
    ));

    expect(find.byKey(const Key('campaign-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('stage-ember_turns_01')));
    expect(selected, isNull);
    await tester.tap(find.byKey(const Key('stage-green_pass_01')));
    expect(selected?.id, 'green_pass_01');
  });

  testWidgets('Stage briefing exposes encounter and starts the stage',
      (tester) async {
    var started = false;
    final session = gameContentIndex.resolveStage('green_pass_01');
    await tester.pumpWidget(_localized(
      StageBriefingScreen(
        session: session,
        onBack: () {},
        onStart: () => started = true,
      ),
    ));

    expect(find.byKey(const Key('briefing-title')), findsOneWidget);
    expect(find.text('3 waves'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('start-stage')),
      300,
    );
    await tester.tap(find.byKey(const Key('start-stage')));
    expect(started, true);
  });

  testWidgets('Results screen presents rewards and continuation',
      (tester) async {
    var continued = false;
    await tester.pumpWidget(_localized(
      StageResultsScreen(
        result: const GameResult(
          stageId: 'green_pass_01',
          victory: true,
          kills: 8,
          wave: 3,
        ),
        stage: campaignStages['green_pass_01']!,
        onCampaign: () {},
        onContinue: () => continued = true,
      ),
    ));

    expect(find.byKey(const Key('results-title')), findsOneWidget);
    expect(find.text('Reward: 100 gold'), findsOneWidget);
    await tester.tap(find.byKey(const Key('continue-stage')));
    expect(continued, true);
  });

  testWidgets('App shell loads progress and navigates into briefing',
      (tester) async {
    await tester.pumpWidget(
      TowerDefApp(progressStore: InMemoryCampaignProgressStore()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('campaign-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('stage-green_pass_01')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('briefing-title')), findsOneWidget);
  });
}

Widget _localized(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('es')],
    home: child,
  );
}
