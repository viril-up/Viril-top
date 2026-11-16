import 'package:flutter/material.dart';

class LeagueEpoch {
  const LeagueEpoch({required this.number, required this.name, required this.subtitle, required this.leagues});
  final int number;
  final String name;
  final String subtitle;
  final List<String> leagues;
}

class LeagueDefinition {
  const LeagueDefinition({required this.number, required this.name, required this.epochNumber, required this.epochName});
  final int number;
  final String name;
  final int epochNumber;
  final String epochName;
  int get firstGlobalLevel => (number - 1) * 3 + 1;
  int get firstXp => (firstGlobalLevel - 1) * 100;
  int get lastXp => firstXp + 200;
  int get nextLeagueXp => firstXp + 300;
  bool get isFinal => number == 60;
  int get levelOneXp => firstXp;
  int get levelTwoXp => firstXp + 100;
  int get levelThreeXp => firstXp + 200;
}

class LeagueSystem {
  LeagueSystem._();
  static const epochs = <LeagueEpoch>[
    LeagueEpoch(number: 1, name: 'СТАНОВЛЕНИЕ', subtitle: 'Фундамент, дисциплина и первые достижения.', leagues: [
      'Железная','Бронзовая','Серебряная','Золотая','Платиновая','Сапфировая','Изумрудная','Рубиновая','Нефритовая','Ониксовая','Кристальная','Обсидиановая',
    ]),
    LeagueEpoch(number: 2, name: 'ПРЕВОСХОДСТВО', subtitle: 'Мастерство, сила воли и исключительные достижения.', leagues: [
      'Хлорофитовая','Мифриловая','Адамантитовая','Люминитовая','Стоическая','Прометеевская','Мастер','Чемпион','Превосходная','Совершенная','Титан','Легенда','Королевская','Императорская','Суверенная','Верховная',
    ]),
    LeagueEpoch(number: 3, name: 'ВОЗВЫШЕНИЕ', subtitle: 'Героизм, легендарность и мифологическое величие.', leagues: [
      'Гиперборейская','Олимпийская','Эфирная','Архонтическая','Мифическая','Вознесённая','Божественная','Просветлённая','Эоническая','Вечная',
    ]),
    LeagueEpoch(number: 4, name: 'ПОЗНАНИЕ', subtitle: 'Мудрость, интеллект, философия и совершенствование сознания.', leagues: [
      'Телеологическая','Эйдетическая','Софическая','Ноэтическая','Аретическая','Гносеологическая','Эпистемическая','Ноуменальная','Абсолютная',
    ]),
    LeagueEpoch(number: 5, name: 'ТРАНСЦЕНДЕНТНОСТЬ', subtitle: 'Бесконечность, космические масштабы и выход за пределы реальности.', leagues: [
      'Сингулярная','Сверхновая','Астральная','Межзвёздная','Галактическая','Космическая','Метагалактическая','Вселенская','Межвселенская','Мультивселенская','Трансцендентная','Запредельная','Омниверсальная',
    ]),
  ];
  static final all = <LeagueDefinition>[
    for (final epoch in epochs)
      for (final name in epoch.leagues)
        LeagueDefinition(number: _numberFor(epoch, name), name: name, epochNumber: epoch.number, epochName: epoch.name),
  ];
  static int _numberFor(LeagueEpoch epoch, String name) {
    var offset = 0;
    for (final item in epochs) { if (item.number == epoch.number) break; offset += item.leagues.length; }
    return offset + epoch.leagues.indexOf(name) + 1;
  }
  static LeagueDefinition forXp(int xp) => all[((xp < 0 ? 0 : xp) ~/ 300).clamp(0, 59)];
  static int globalLevelForXp(int xp) => ((xp < 0 ? 0 : xp) ~/ 100) + 1;
  static int levelWithinLeagueForXp(int xp) => (((xp < 0 ? 0 : xp) ~/ 100) % 3) + 1;
  static int xpIntoLevel(int xp) => (xp < 0 ? 0 : xp) % 100;
  static int get totalLeagues => all.length;
  static int get totalLevels => all.length * 3;
}
