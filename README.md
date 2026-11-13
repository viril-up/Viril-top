# Viril

Viril — Flutter-приложение для комплексного саморазвития: физического, ментального, интеллектуального и духовного.

## Разделы
1. Главная
2. Развитие
3. Ресурсы
4. Прогресс
5. Профиль (включая глобальную лигу)

## Архитектура
Каждый раздел находится в отдельной папке `lib/features/<module>`. Общая тема, фон, навигация и компоненты находятся в `lib/core`.

## Запуск
```bash
flutter pub get
flutter run
```

## Сборка Web
```bash
flutter build web --release --base-href /Viril-top/
```

## Сборка Android APK
```bash
flutter build apk --release
```

Визуальная система использует Flutter gradients, custom painting, layered surfaces и мягкие glow-эффекты. Это позволяет сохранить единый интерфейс в Web и Android без отдельной 3D-движковой зависимости.
