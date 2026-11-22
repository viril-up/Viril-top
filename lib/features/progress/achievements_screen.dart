import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/data/viril_store.dart';
import '../habits/data/habit_store.dart';
import '../goals/data/goal_store.dart';

enum _Kind { physical, spiritual, mental, intellectual, general }
enum _Tier { easy, medium, hard, extreme }

class _Award {
  const _Award(this.title, this.description, this.kind, this.tier, this.icon, this.test);
  final String title, description;
  final _Kind kind;
  final _Tier tier;
  final IconData icon;
  final bool Function(VirilStore, HabitStore, GoalStore) test;
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  static final List<_Award> _awards = [
    _Award('Первый шаг', 'Выполни первую задачу', _Kind.physical, _Tier.easy, Icons.directions_walk_rounded, (s,h,g)=>s.completedCount>=1),
    _Award('Три дня движения', 'Будь активен 3 дня подряд', _Kind.physical, _Tier.easy, Icons.bolt_rounded, (s,h,g)=>s.activeDaysStreak>=3),
    _Award('Пять привычек', 'Сделай 5 отметок привычек', _Kind.physical, _Tier.easy, Icons.repeat_rounded, (s,h,g)=>h.totalCompletions>=5),
    _Award('Неделя движения', 'Сохраняй активность 7 дней подряд', _Kind.physical, _Tier.medium, Icons.directions_run_rounded, (s,h,g)=>s.activeDaysStreak>=7),
    _Award('Тридцать повторений', 'Набери 30 отметок привычек', _Kind.physical, _Tier.medium, Icons.fitness_center_rounded, (s,h,g)=>h.totalCompletions>=30),
    _Award('Стальной ритм', 'Активность 14 дней подряд', _Kind.physical, _Tier.hard, Icons.local_fire_department_rounded, (s,h,g)=>s.activeDaysStreak>=14),
    _Award('Месяц дисциплины', 'Активность 30 дней подряд', _Kind.physical, _Tier.extreme, Icons.military_tech_rounded, (s,h,g)=>s.activeDaysStreak>=30),
    _Award('Сотня привычек', 'Набери 100 отметок привычек', _Kind.physical, _Tier.hard, Icons.sports_gymnastics_rounded, (s,h,g)=>h.totalCompletions>=100),
    _Award('Мастер регулярности', 'Набери 300 отметок привычек', _Kind.physical, _Tier.extreme, Icons.workspace_premium_rounded, (s,h,g)=>h.totalCompletions>=300),

    _Award('Тихая минута', 'Создай первую запись благодарности', _Kind.spiritual, _Tier.easy, Icons.spa_rounded, (s,h,g)=>s.gratitudeEntries.isNotEmpty),
    _Award('Пять благодарностей', 'Сохрани 5 записей благодарности', _Kind.spiritual, _Tier.medium, Icons.favorite_rounded, (s,h,g)=>s.gratitudeEntries.length>=5),
    _Award('Свет внутри', 'Сохрани 20 записей благодарности', _Kind.spiritual, _Tier.hard, Icons.wb_twilight_rounded, (s,h,g)=>s.gratitudeEntries.length>=20),
    _Award('Практика благодарности', 'Сохрани 50 записей благодарности', _Kind.spiritual, _Tier.extreme, Icons.self_improvement_rounded, (s,h,g)=>s.gratitudeEntries.length>=50),
    _Award('Четыре опоры', 'Достигни 10-го уровня во всех четырёх направлениях', _Kind.spiritual, _Tier.hard, Icons.balance_rounded, (s,h,g)=>s.domainLevel('Физическое')>=10 && s.domainLevel('Ментальное')>=10 && s.domainLevel('Интеллект')>=10 && s.domainLevel('Духовное')>=10),
    _Award('Гармония', 'Достигни 25-го уровня во всех четырёх направлениях', _Kind.spiritual, _Tier.extreme, Icons.self_improvement_rounded, (s,h,g)=>s.domainLevel('Физическое')>=25 && s.domainLevel('Ментальное')>=25 && s.domainLevel('Интеллект')>=25 && s.domainLevel('Духовное')>=25),

    _Award('Мысли на бумаге', 'Создай первую запись в дневнике', _Kind.mental, _Tier.easy, Icons.edit_note_rounded, (s,h,g)=>s.journalEntries.isNotEmpty),
    _Award('Десять размышлений', 'Сохрани 10 записей в дневнике', _Kind.mental, _Tier.medium, Icons.psychology_alt_rounded, (s,h,g)=>s.journalEntries.length>=10),
    _Award('Глубина мысли', 'Сохрани 20 записей в дневнике', _Kind.mental, _Tier.hard, Icons.lightbulb_rounded, (s,h,g)=>s.journalEntries.length>=20),
    _Award('Хроника сознания', 'Сохрани 50 записей в дневнике', _Kind.mental, _Tier.extreme, Icons.auto_awesome_rounded, (s,h,g)=>s.journalEntries.length>=50),
    _Award('Серия фокуса', 'Будь активен 7 дней подряд', _Kind.mental, _Tier.medium, Icons.center_focus_strong_rounded, (s,h,g)=>s.activeDaysStreak>=7),
    _Award('Несгибаемый фокус', 'Будь активен 21 день подряд', _Kind.mental, _Tier.hard, Icons.psychology_rounded, (s,h,g)=>s.activeDaysStreak>=21),

    _Award('Первые знания', 'Выполни 5 задач', _Kind.intellectual, _Tier.easy, Icons.menu_book_rounded, (s,h,g)=>s.completedCount>=5),
    _Award('Любознательность', 'Выполни 25 задач', _Kind.intellectual, _Tier.medium, Icons.school_rounded, (s,h,g)=>s.completedCount>=25),
    _Award('Исследователь', 'Выполни 75 задач', _Kind.intellectual, _Tier.hard, Icons.travel_explore_rounded, (s,h,g)=>s.completedCount>=75),
    _Award('Энциклопедист', 'Выполни 200 задач', _Kind.intellectual, _Tier.extreme, Icons.auto_stories_rounded, (s,h,g)=>s.completedCount>=200),
    _Award('Первые 500 XP', 'Набери 500 очков опыта', _Kind.intellectual, _Tier.medium, Icons.stars_rounded, (s,h,g)=>s.xp>=500),
    _Award('Тысячник', 'Набери 1 000 XP', _Kind.intellectual, _Tier.hard, Icons.bolt_rounded, (s,h,g)=>s.xp>=1000),
    _Award('Мастер опыта', 'Набери 5 000 XP', _Kind.intellectual, _Tier.extreme, Icons.workspace_premium_rounded, (s,h,g)=>s.xp>=5000),

    _Award('Начало пути', 'Создай первый план или задачу', _Kind.general, _Tier.easy, Icons.flag_rounded, (s,h,g)=>s.tasks.isNotEmpty),
    _Award('Целеустремлённость', 'Заверши 3 долгосрочные цели', _Kind.general, _Tier.medium, Icons.task_alt_rounded, (s,h,g)=>g.completedGoals>=3),
    _Award('Стратег', 'Заверши 5 целей и 25 шагов', _Kind.general, _Tier.hard, Icons.route_rounded, (s,h,g)=>g.completedGoals>=5 && g.completedSteps>=25),
    _Award('Архитектор планов', 'Заверши 10 долгосрочных целей', _Kind.general, _Tier.extreme, Icons.account_tree_rounded, (s,h,g)=>g.completedGoals>=10),
    _Award('Первый уровень', 'Достигни 2-го уровня Viril', _Kind.general, _Tier.easy, Icons.trending_up_rounded, (s,h,g)=>s.level>=2),
    _Award('Десятый уровень', 'Достигни 10-го уровня Viril', _Kind.general, _Tier.medium, Icons.military_tech_rounded, (s,h,g)=>s.level>=10),
    _Award('Покоритель уровней', 'Достигни 25-го уровня Viril', _Kind.general, _Tier.hard, Icons.emoji_events_rounded, (s,h,g)=>s.level>=25),
    _Award('Вершина системы', 'Достигни 50-го уровня Viril', _Kind.general, _Tier.extreme, Icons.workspace_premium_rounded, (s,h,g)=>s.level>=50),
    _Award('Первая награда', 'Получи 10 V-Coin', _Kind.general, _Tier.easy, Icons.monetization_on_rounded, (s,h,g)=>s.vcoins>=10),
    _Award('Коллекционер V-Coin', 'Получи 50 V-Coin', _Kind.general, _Tier.medium, Icons.toll_rounded, (s,h,g)=>s.vcoins>=50),
    _Award('Капитал прогресса', 'Получи 150 V-Coin', _Kind.general, _Tier.hard, Icons.savings_rounded, (s,h,g)=>s.vcoins>=150),
    _Award('Золотой резерв', 'Получи 500 V-Coin', _Kind.general, _Tier.extreme, Icons.diamond_rounded, (s,h,g)=>s.vcoins>=500),
    _Award('Первая покупка', 'Приобрети первый предмет в магазине', _Kind.general, _Tier.easy, Icons.shopping_bag_rounded, (s,h,g)=>s.purchasedItemsCount>=1),
    _Award('Коллекция растёт', 'Приобрети 5 предметов в магазине', _Kind.general, _Tier.medium, Icons.inventory_2_rounded, (s,h,g)=>s.purchasedItemsCount>=5),
    _Award('Коллекционер', 'Приобрети 10 предметов в магазине', _Kind.general, _Tier.hard, Icons.collections_bookmark_rounded, (s,h,g)=>s.purchasedItemsCount>=10),
    _Award('Хозяин магазина', 'Приобрети 20 предметов в магазине', _Kind.general, _Tier.extreme, Icons.storefront_rounded, (s,h,g)=>s.purchasedItemsCount>=20),
    _Award('Бронзовая лига', 'Набери 500 XP и достигни Серебряной лиги', _Kind.general, _Tier.medium, Icons.shield_rounded, (s,h,g)=>s.xp>=500),
    _Award('Золотая лига', 'Набери 1 000 XP', _Kind.general, _Tier.hard, Icons.military_tech_rounded, (s,h,g)=>s.xp>=1000),
    _Award('Обсидиановая лига', 'Набери 2 000 XP', _Kind.general, _Tier.extreme, Icons.diamond_rounded, (s,h,g)=>s.xp>=2000),
    _Award('Постоянный участник', 'Набери 30 активных дней', _Kind.general, _Tier.medium, Icons.calendar_month_rounded, (s,h,g)=>s.activeDaysCount>=30),
    _Award('Полгода движения', 'Набери 180 активных дней', _Kind.general, _Tier.hard, Icons.event_available_rounded, (s,h,g)=>s.activeDaysCount>=180),
    _Award('Легенда Viril', '5 000 XP, 90 активных дней, 100 задач, 150 отметок привычек и 10 завершённых целей', _Kind.general, _Tier.extreme, Icons.emoji_events_rounded, (s,h,g)=>s.xp>=5000 && s.activeDaysCount>=90 && s.completedCount>=100 && h.totalCompletions>=150 && g.completedGoals>=10),
    _Award('Планировщик', 'Создай 3 задачи', _Kind.general, _Tier.easy, Icons.playlist_add_check_rounded, (s,h,g)=>s.tasks.length>=3),
    _Award('Десять дел', 'Создай 10 задач', _Kind.general, _Tier.medium, Icons.checklist_rounded, (s,h,g)=>s.tasks.length>=10),
    _Award('Большой список', 'Создай 25 задач', _Kind.general, _Tier.hard, Icons.view_list_rounded, (s,h,g)=>s.tasks.length>=25),
    _Award('Мастер организации', 'Создай 50 задач', _Kind.general, _Tier.extreme, Icons.fact_check_rounded, (s,h,g)=>s.tasks.length>=50),
    _Award('Шаг за шагом', 'Заверши 10 задач', _Kind.general, _Tier.easy, Icons.done_all_rounded, (s,h,g)=>s.completedCount>=10),
    _Award('Двадцать пять побед', 'Заверши 25 задач', _Kind.general, _Tier.medium, Icons.task_alt_rounded, (s,h,g)=>s.completedCount>=25),
    _Award('Пятьдесят выполненных', 'Заверши 50 задач', _Kind.general, _Tier.hard, Icons.verified_rounded, (s,h,g)=>s.completedCount>=50),
    _Award('Сотня выполненных дел', 'Заверши 100 задач', _Kind.general, _Tier.extreme, Icons.emoji_events_rounded, (s,h,g)=>s.completedCount>=100),
    _Award('Первые шаги к цели', 'Заверши 5 шагов целей', _Kind.general, _Tier.easy, Icons.route_rounded, (s,h,g)=>g.completedSteps>=5),
    _Award('Десять шагов', 'Заверши 10 шагов целей', _Kind.general, _Tier.medium, Icons.signpost_rounded, (s,h,g)=>g.completedSteps>=10),
    _Award('Пятьдесят шагов', 'Заверши 50 шагов целей', _Kind.general, _Tier.hard, Icons.alt_route_rounded, (s,h,g)=>g.completedSteps>=50),
    _Award('Сто шагов к мечте', 'Заверши 100 шагов целей', _Kind.general, _Tier.extreme, Icons.explore_rounded, (s,h,g)=>g.completedSteps>=100),
    _Award('Опыт новичка', 'Набери 100 XP', _Kind.general, _Tier.easy, Icons.stars_rounded, (s,h,g)=>s.xp>=100),
    _Award('Путь опыта', 'Набери 750 XP', _Kind.general, _Tier.medium, Icons.bolt_rounded, (s,h,g)=>s.xp>=750),
    _Award('Две тысячи XP', 'Набери 2 000 XP', _Kind.general, _Tier.hard, Icons.flash_on_rounded, (s,h,g)=>s.xp>=2000),
    _Award('Десять тысяч XP', 'Набери 10 000 XP', _Kind.general, _Tier.extreme, Icons.auto_awesome_rounded, (s,h,g)=>s.xp>=10000),
    _Award('Уровень 5', 'Достигни 5-го уровня Viril', _Kind.general, _Tier.easy, Icons.trending_up_rounded, (s,h,g)=>s.level>=5),
    _Award('Уровень 15', 'Достигни 15-го уровня Viril', _Kind.general, _Tier.medium, Icons.military_tech_rounded, (s,h,g)=>s.level>=15),
    _Award('Уровень 30', 'Достигни 30-го уровня Viril', _Kind.general, _Tier.hard, Icons.workspace_premium_rounded, (s,h,g)=>s.level>=30),
    _Award('Уровень 75', 'Достигни 75-го уровня Viril', _Kind.general, _Tier.extreme, Icons.diamond_rounded, (s,h,g)=>s.level>=75),
    _Award('Три активных дня', 'Набери 3 активных дня', _Kind.general, _Tier.easy, Icons.calendar_today_rounded, (s,h,g)=>s.activeDaysCount>=3),
    _Award('Десять активных дней', 'Набери 10 активных дней', _Kind.general, _Tier.medium, Icons.date_range_rounded, (s,h,g)=>s.activeDaysCount>=10),
    _Award('Шестьдесят активных дней', 'Набери 60 активных дней', _Kind.general, _Tier.hard, Icons.calendar_month_rounded, (s,h,g)=>s.activeDaysCount>=60),
    _Award('Триста активных дней', 'Набери 300 активных дней', _Kind.general, _Tier.extreme, Icons.event_available_rounded, (s,h,g)=>s.activeDaysCount>=300),
    _Award('Первые десять привычек', 'Набери 10 отметок привычек', _Kind.physical, _Tier.easy, Icons.repeat_rounded, (s,h,g)=>h.totalCompletions>=10),
    _Award('Пятьдесят привычек', 'Набери 50 отметок привычек', _Kind.physical, _Tier.medium, Icons.loop_rounded, (s,h,g)=>h.totalCompletions>=50),
    _Award('Двести привычек', 'Набери 200 отметок привычек', _Kind.physical, _Tier.hard, Icons.fitness_center_rounded, (s,h,g)=>h.totalCompletions>=200),
    _Award('Пятьсот привычек', 'Набери 500 отметок привычек', _Kind.physical, _Tier.extreme, Icons.sports_score_rounded, (s,h,g)=>h.totalCompletions>=500),
    _Award('Первая цель', 'Заверши 1 цель', _Kind.general, _Tier.easy, Icons.flag_circle_rounded, (s,h,g)=>g.completedGoals>=1),
    _Award('Семь целей', 'Заверши 7 целей', _Kind.general, _Tier.medium, Icons.outlined_flag_rounded, (s,h,g)=>g.completedGoals>=7),
    _Award('Двадцать целей', 'Заверши 20 целей', _Kind.general, _Tier.hard, Icons.navigation_rounded, (s,h,g)=>g.completedGoals>=20),
    _Award('Пятьдесят целей', 'Заверши 50 целей', _Kind.general, _Tier.extreme, Icons.emoji_flags_rounded, (s,h,g)=>g.completedGoals>=50),
    _Award('Первая запись', 'Сделай 1 запись в дневнике', _Kind.mental, _Tier.easy, Icons.note_add_rounded, (s,h,g)=>s.journalEntries.length>=1),
    _Award('Тридцать записей', 'Сохрани 30 записей в дневнике', _Kind.mental, _Tier.medium, Icons.library_books_rounded, (s,h,g)=>s.journalEntries.length>=30),
    _Award('Семьдесят пять записей', 'Сохрани 75 записей в дневнике', _Kind.mental, _Tier.hard, Icons.menu_book_rounded, (s,h,g)=>s.journalEntries.length>=75),
    _Award('Сто записей', 'Сохрани 100 записей в дневнике', _Kind.mental, _Tier.extreme, Icons.auto_stories_rounded, (s,h,g)=>s.journalEntries.length>=100),
    _Award('Три благодарности', 'Сохрани 3 записи благодарности', _Kind.spiritual, _Tier.easy, Icons.favorite_border_rounded, (s,h,g)=>s.gratitudeEntries.length>=3),
    _Award('Десять благодарностей', 'Сохрани 10 записей благодарности', _Kind.spiritual, _Tier.medium, Icons.volunteer_activism_rounded, (s,h,g)=>s.gratitudeEntries.length>=10),
    _Award('Тридцать благодарностей', 'Сохрани 30 записей благодарности', _Kind.spiritual, _Tier.hard, Icons.wb_sunny_rounded, (s,h,g)=>s.gratitudeEntries.length>=30),
    _Award('Сто благодарностей', 'Сохрани 100 записей благодарности', _Kind.spiritual, _Tier.extreme, Icons.spa_rounded, (s,h,g)=>s.gratitudeEntries.length>=100),
    _Award('Первые 25 V-Coin', 'Накопи 25 V-Coin', _Kind.general, _Tier.easy, Icons.monetization_on_rounded, (s,h,g)=>s.vcoins>=25),
    _Award('250 V-Coin', 'Накопи 250 V-Coin', _Kind.general, _Tier.medium, Icons.toll_rounded, (s,h,g)=>s.vcoins>=250),
    _Award('750 V-Coin', 'Накопи 750 V-Coin', _Kind.general, _Tier.hard, Icons.savings_rounded, (s,h,g)=>s.vcoins>=750),
    _Award('1 500 V-Coin', 'Накопи 1 500 V-Coin', _Kind.general, _Tier.extreme, Icons.diamond_rounded, (s,h,g)=>s.vcoins>=1500),
    _Award('Вторая покупка', 'Приобрети 2 предмета в магазине', _Kind.general, _Tier.easy, Icons.shopping_cart_rounded, (s,h,g)=>s.purchasedItemsCount>=2),
    _Award('Три покупки', 'Приобрети 3 предмета в магазине', _Kind.general, _Tier.medium, Icons.add_shopping_cart_rounded, (s,h,g)=>s.purchasedItemsCount>=3),
    _Award('Пятнадцать покупок', 'Приобрети 15 предметов в магазине', _Kind.general, _Tier.hard, Icons.store_rounded, (s,h,g)=>s.purchasedItemsCount>=15),
    _Award('Тридцать покупок', 'Приобрети 30 предметов в магазине', _Kind.general, _Tier.extreme, Icons.storefront_rounded, (s,h,g)=>s.purchasedItemsCount>=30),
    _Award('Физический рост', 'Достигни 5-го уровня физического направления', _Kind.physical, _Tier.easy, Icons.directions_run_rounded, (s,h,g)=>s.domainLevel('Физическое')>=5),
    _Award('Сила постоянства', 'Достигни 15-го уровня физического направления', _Kind.physical, _Tier.medium, Icons.fitness_center_rounded, (s,h,g)=>s.domainLevel('Физическое')>=15),
  ];

  @override
  void initState() {
    super.initState();
    VirilStore.instance.initialize();
    HabitStore.instance.initialize();
    GoalStore.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final store=VirilStore.instance, habits=HabitStore.instance, goals=GoalStore.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([store, habits, goals]),
      builder: (context, _) {
        final list=_awards;
        final unlocked=_awards.where((a)=>a.test(store,habits,goals)).length;
        return Scaffold(
          appBar: AppBar(title: const Text('Твои достижения')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(colors:[Color(0xFF30291F),Color(0xFF111923)],begin:Alignment.topLeft,end:Alignment.bottomRight),
                  border: Border.all(color:VirilColors.gold.withValues(alpha:.35)),
                ),
                child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  const Text('ТВОЙ ПУТЬ МАСТЕРСТВА',style:TextStyle(color:VirilColors.gold,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.4)),
                  const SizedBox(height:8),
                  Text('$unlocked из ${_awards.length} открыто',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),
                  const SizedBox(height:9),
                  ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:unlocked/_awards.length,minHeight:7,backgroundColor:VirilColors.line,color:VirilColors.gold)),
                  const SizedBox(height:5),
                  const Text('Достижения открываются автоматически по мере твоего прогресса.',style:TextStyle(color:VirilColors.muted,fontSize:10)),
                ]),
              ),
              const SizedBox(height:16),
              Text('${list.where((a)=>a.test(store,habits,goals)).length} / ${list.length} открыто',style:const TextStyle(color:VirilColors.muted,fontSize:11,fontWeight:FontWeight.w700)),
              const SizedBox(height:8),
              for(final a in list) _awardTile(a,store,habits,goals),
            ],
          ),
        );
      },
    );
  }

  Widget _awardTile(_Award a,VirilStore s,HabitStore h,GoalStore g) {
    final done=a.test(s,h,g);
    return Container(
      margin:const EdgeInsets.only(bottom:8),
      padding:const EdgeInsets.all(12),
      decoration:BoxDecoration(color:VirilColors.stone,borderRadius:BorderRadius.circular(15),border:Border.all(color:done?VirilColors.gold.withValues(alpha:.45):VirilColors.line)),
      child:Row(children:[
        Container(width:42,height:42,decoration:BoxDecoration(shape:BoxShape.circle,color:(done?VirilColors.gold:VirilColors.muted).withValues(alpha:.13)),child:Icon(a.icon,color:done?VirilColors.gold:VirilColors.muted,size:21)),
        const SizedBox(width:11),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(a.title,style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,color:done?VirilColors.text:VirilColors.muted)),
          const SizedBox(height:3),
          Text(a.description,style:const TextStyle(fontSize:10,color:VirilColors.muted,height:1.35)),
        ])),
        const SizedBox(width:8),
        Icon(done?Icons.check_circle_rounded:Icons.lock_outline_rounded,color:done?VirilColors.gold:VirilColors.subdued,size:19),
      ]),
    );
  }
}
