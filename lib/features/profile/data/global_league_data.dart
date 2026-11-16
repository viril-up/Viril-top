import 'package:flutter/material.dart';

class LeagueEpoch {
  const LeagueEpoch({required this.name, required this.subtitle, required this.leagues});
  final String name;
  final String subtitle;
  final List<String> leagues;
}

class GlobalLeagueData {
  static const epochs = <LeagueEpoch>[
    LeagueEpoch(name: 'I ЭПОХА — СТАНОВЛЕНИЕ', subtitle: 'Фундамент, дисциплина и первые достижения.', leagues: ['Железная','Бронзовая','Серебряная','Золотая','Платиновая','Сапфировая','Изумрудная','Рубиновая','Нефритовая','Ониксовая','Кристальная','Обсидиановая']),
    LeagueEpoch(name: 'II ЭПОХА — ПРЕВОСХОДСТВО', subtitle: 'Мастерство, сила воли и исключительные достижения.', leagues: ['Хлорофитовая','Мифриловая','Адамантитовая','Люминитовая','Стоическая','Прометеевская','Мастер','Чемпион','Превосходная','Совершенная','Титан','Легенда','Королевская','Императорская','Суверенная','Верховная']),
    LeagueEpoch(name: 'III ЭПОХА — ВОЗВЫШЕНИЕ', subtitle: 'Героизм, легендарность и мифологическое величие.', leagues: ['Гиперборейская','Олимпийская','Эфирная','Архонтическая','Мифическая','Вознесённая','Божественная','Просветлённая','Эоническая','Вечная']),
    LeagueEpoch(name: 'IV ЭПОХА — ПОЗНАНИЕ', subtitle: 'Мудрость, интеллект, философия и совершенствование сознания.', leagues: ['Телеологическая','Эйдетическая','Софическая','Ноэтическая','Аретическая','Гносеологическая','Эпистемическая','Ноуменальная','Абсолютная']),
    LeagueEpoch(name: 'V ЭПОХА — ТРАНСЦЕНДЕНТНОСТЬ', subtitle: 'Бесконечность, космические масштабы и выход за пределы реальности.', leagues: ['Сингулярная','Сверхновая','Астральная','Межзвёздная','Галактическая','Космическая','Метагалактическая','Вселенская','Межвселенская','Мультивселенская','Трансцендентная','Запредельная','Омниверсальная']),
  ];

  static final allLeagues = epochs.expand((e) => e.leagues).toList(growable: false);
  static int levelForXp(int xp) => (xp ~/ 100 + 1).clamp(1, 180);
  static int leagueIndexForXp(int xp) => ((levelForXp(xp) - 1) ~/ 3).clamp(0, 59);
  static int tierForXp(int xp) => ((levelForXp(xp) - 1) % 3) + 1;
  static int xpAtLevel(int level) => (level - 1) * 100;
  static int xpToNextLevel(int xp) => levelForXp(xp) >= 180 ? 0 : 100 - (xp % 100);
  static int epochIndexForLeague(int leagueIndex) {
    var total = 0;
    for (var i = 0; i < epochs.length; i++) {
      total += epochs[i].leagues.length;
      if (leagueIndex < total) return i;
    }
    return epochs.length - 1;
  }
  static int epochStartLeague(int epochIndex) {
    var total = 0;
    for (var i = 0; i < epochIndex; i++) { total += epochs[i].leagues.length; }
    return total;
  }
  static int epochEndLeague(int epochIndex) =>
      epochStartLeague(epochIndex) + epochs[epochIndex].leagues.length - 1;
  static Color colorForLeague(int index) {
    if (index < 12) return const Color(0xFFC28A58);
    if (index < 28) return const Color(0xFFB7A4E5);
    if (index < 38) return const Color(0xFF75C8D8);
    if (index < 47) return const Color(0xFF9AC7A5);
    return const Color(0xFFE0C27A);
  }
}
