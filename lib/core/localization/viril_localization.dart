import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const virilLanguageNames = <String, String>{
  'Русский': 'ru', 'Украинский': 'uk', 'Английский': 'en',
  'Французский': 'fr', 'Немецкий': 'de', 'Испанский': 'es',
  'Китайский': 'zh', 'Корейский': 'ko', 'Японский': 'ja',
  'Индийский (хинди)': 'hi', 'Арабский': 'ar', 'Турецкий': 'tr',
  'Туркменский': 'tk',
};

class VirilLanguageController extends ChangeNotifier {
  VirilLanguageController._();
  static final instance = VirilLanguageController._();
  static const _preferenceKey = 'viril.profile.language.v1';
  Locale _locale = const Locale('ru');
  Locale get locale => _locale;
  String get languageName => virilLanguageNames.entries
      .firstWhere((entry) => entry.value == _locale.languageCode,
          orElse: () => const MapEntry('Русский', 'ru')).key;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_preferenceKey) ?? 'Русский';
      _locale = Locale(virilLanguageNames[saved] ?? 'ru');
    } catch (error) {
      debugPrint('Viril language preference could not be loaded: $error');
      _locale = const Locale('ru');
    }
  }

  Future<void> setLanguage(String name) async {
    final code = virilLanguageNames[name];
    if (code == null || _locale.languageCode == code) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, name);
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> reset() async {
    _locale = const Locale('ru');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferenceKey);
    notifyListeners();
  }
}

class VirilStrings {
  const VirilStrings(this.locale);
  final Locale locale;
  static VirilStrings of(BuildContext context) =>
      Localizations.of<VirilStrings>(context, VirilStrings)!;
  String t(String key) => _translations[locale.languageCode]?[key] ??
      _navigationTranslations[locale.languageCode]?[key] ??
      _translations['ru']![key] ?? _navigationTranslations['ru']?[key] ?? key;

  static const delegate = _VirilStringsDelegate();
}

class _VirilStringsDelegate extends LocalizationsDelegate<VirilStrings> {
  const _VirilStringsDelegate();
  @override bool isSupported(Locale locale) =>
      virilLanguageNames.values.contains(locale.languageCode);
  @override Future<VirilStrings> load(Locale locale) =>
      SynchronousFuture(VirilStrings(locale));
  @override bool shouldReload(_VirilStringsDelegate old) => false;
}

const Map<String, Map<String, String>> _translations = {
  "ru": {
    "settings": "Настройки",
    "personalization": "ПЕРСОНАЛИЗАЦИЯ",
    "language": "Язык",
    "data": "УПРАВЛЕНИЕ ДАННЫМИ",
    "resetProgress": "Сброс прогресса",
    "resetSubtitle": "Удалить XP, задачи, активность и записи",
    "deleteAccount": "Удаление аккаунта",
    "deleteSubtitle": "Удалить локальный профиль и прогресс",
    "information": "ИНФОРМАЦИЯ",
    "privacy": "Конфиденциальность",
    "privacySubtitle": "Как хранятся и используются данные",
    "about": "О приложении",
    "aboutSubtitle": "Версия, назначение и контакты",
    "languageTitle": "ЯЗЫК ПРИЛОЖЕНИЯ",
    "languageSaved": "Язык приложения изменён.",
    "goals": "Мои цели",
    "active": "активные",
    "day": "День",
    "week": "Неделя",
    "month": "Месяц",
    "year": "Год",
    "emptyGoals": "Здесь появятся твои цели",
    "addFirst": "Нажми + и создай первую",
    "cancel": "Отмена",
    "confirm": "Подтвердить"
  },
  "uk": {
    "settings": "Налаштування",
    "personalization": "ПЕРСОНАЛІЗАЦІЯ",
    "language": "Мова",
    "data": "КЕРУВАННЯ ДАНИМИ",
    "resetProgress": "Скинути прогрес",
    "resetSubtitle": "Видалити XP, завдання, активність і записи",
    "deleteAccount": "Видалення облікового запису",
    "deleteSubtitle": "Видалити локальний профіль і прогрес",
    "information": "ІНФОРМАЦІЯ",
    "privacy": "Конфіденційність",
    "privacySubtitle": "Як зберігаються та використовуються дані",
    "about": "Про застосунок",
    "aboutSubtitle": "Версія, призначення та контакти",
    "languageTitle": "МОВА ЗАСТОСУНКУ",
    "languageSaved": "Мову застосунку змінено.",
    "goals": "Мої цілі",
    "active": "активні",
    "day": "День",
    "week": "Тиждень",
    "month": "Місяць",
    "year": "Рік",
    "emptyGoals": "Тут з’являться твої цілі",
    "addFirst": "Натисни + і створи першу",
    "cancel": "Скасувати",
    "confirm": "Підтвердити"
  },
  "en": {
    "settings": "Settings",
    "personalization": "PERSONALIZATION",
    "language": "Language",
    "data": "DATA MANAGEMENT",
    "resetProgress": "Reset progress",
    "resetSubtitle": "Delete XP, tasks, activity and entries",
    "deleteAccount": "Delete account",
    "deleteSubtitle": "Delete local profile and progress",
    "information": "INFORMATION",
    "privacy": "Privacy",
    "privacySubtitle": "How your data is stored and used",
    "about": "About the app",
    "aboutSubtitle": "Version, purpose and contacts",
    "languageTitle": "APP LANGUAGE",
    "languageSaved": "App language changed.",
    "goals": "My goals",
    "active": "active",
    "day": "Day",
    "week": "Week",
    "month": "Month",
    "year": "Year",
    "emptyGoals": "Your goals will appear here",
    "addFirst": "Tap + to create your first goal",
    "cancel": "Cancel",
    "confirm": "Confirm"
  },
  "fr": {
    "settings": "Paramètres",
    "personalization": "PERSONNALISATION",
    "language": "Langue",
    "data": "GESTION DES DONNÉES",
    "resetProgress": "Réinitialiser la progression",
    "resetSubtitle": "Supprimer XP, tâches, activité et notes",
    "deleteAccount": "Supprimer le compte",
    "deleteSubtitle": "Supprimer le profil local et la progression",
    "information": "INFORMATIONS",
    "privacy": "Confidentialité",
    "privacySubtitle": "Stockage et utilisation de vos données",
    "about": "À propos",
    "aboutSubtitle": "Version, objectif et contacts",
    "languageTitle": "LANGUE DE L’APPLICATION",
    "languageSaved": "La langue de l’application a changé.",
    "goals": "Mes objectifs",
    "active": "actives",
    "day": "Jour",
    "week": "Semaine",
    "month": "Mois",
    "year": "Année",
    "emptyGoals": "Vos objectifs apparaîtront ici",
    "addFirst": "Appuyez sur + pour créer le premier",
    "cancel": "Annuler",
    "confirm": "Confirmer"
  },
  "de": {
    "settings": "Einstellungen",
    "personalization": "PERSONALISIERUNG",
    "language": "Sprache",
    "data": "DATENVERWALTUNG",
    "resetProgress": "Fortschritt zurücksetzen",
    "resetSubtitle": "XP, Aufgaben, Aktivität und Einträge löschen",
    "deleteAccount": "Konto löschen",
    "deleteSubtitle": "Lokales Profil und Fortschritt löschen",
    "information": "INFORMATIONEN",
    "privacy": "Datenschutz",
    "privacySubtitle": "Speicherung und Nutzung deiner Daten",
    "about": "Über die App",
    "aboutSubtitle": "Version, Zweck und Kontakte",
    "languageTitle": "APP-SPRACHE",
    "languageSaved": "App-Sprache geändert.",
    "goals": "Meine Ziele",
    "active": "aktiv",
    "day": "Tag",
    "week": "Woche",
    "month": "Monat",
    "year": "Jahr",
    "emptyGoals": "Deine Ziele erscheinen hier",
    "addFirst": "Tippe auf +, um dein erstes Ziel zu erstellen",
    "cancel": "Abbrechen",
    "confirm": "Bestätigen"
  },
  "es": {
    "settings": "Ajustes",
    "personalization": "PERSONALIZACIÓN",
    "language": "Idioma",
    "data": "GESTIÓN DE DATOS",
    "resetProgress": "Restablecer progreso",
    "resetSubtitle": "Eliminar XP, tareas, actividad y notas",
    "deleteAccount": "Eliminar cuenta",
    "deleteSubtitle": "Eliminar perfil local y progreso",
    "information": "INFORMACIÓN",
    "privacy": "Privacidad",
    "privacySubtitle": "Cómo se almacenan y utilizan tus datos",
    "about": "Acerca de la app",
    "aboutSubtitle": "Versión, propósito y contactos",
    "languageTitle": "IDIOMA DE LA APLICACIÓN",
    "languageSaved": "Se cambió el idioma de la aplicación.",
    "goals": "Mis objetivos",
    "active": "activos",
    "day": "Día",
    "week": "Semana",
    "month": "Mes",
    "year": "Año",
    "emptyGoals": "Tus objetivos aparecerán aquí",
    "addFirst": "Pulsa + para crear el primero",
    "cancel": "Cancelar",
    "confirm": "Confirmar"
  },
  "zh": {
    "settings": "设置",
    "personalization": "个性化",
    "language": "语言",
    "data": "数据管理",
    "resetProgress": "重置进度",
    "resetSubtitle": "删除 XP、任务、活动和记录",
    "deleteAccount": "删除账户",
    "deleteSubtitle": "删除本地资料和进度",
    "information": "信息",
    "privacy": "隐私",
    "privacySubtitle": "数据的存储和使用方式",
    "about": "关于应用",
    "aboutSubtitle": "版本、用途和联系方式",
    "languageTitle": "应用语言",
    "languageSaved": "应用语言已更改。",
    "goals": "我的目标",
    "active": "项进行中",
    "day": "日",
    "week": "周",
    "month": "月",
    "year": "年",
    "emptyGoals": "你的目标将显示在这里",
    "addFirst": "点击 + 创建第一个目标",
    "cancel": "取消",
    "confirm": "确认"
  },
  "ko": {
    "settings": "설정",
    "personalization": "개인 설정",
    "language": "언어",
    "data": "데이터 관리",
    "resetProgress": "진행 상황 초기화",
    "resetSubtitle": "XP, 작업, 활동 및 기록 삭제",
    "deleteAccount": "계정 삭제",
    "deleteSubtitle": "로컬 프로필 및 진행 상황 삭제",
    "information": "정보",
    "privacy": "개인정보 보호",
    "privacySubtitle": "데이터 저장 및 사용 방식",
    "about": "앱 정보",
    "aboutSubtitle": "버전, 목적 및 연락처",
    "languageTitle": "앱 언어",
    "languageSaved": "앱 언어가 변경되었습니다.",
    "goals": "내 목표",
    "active": "진행 중",
    "day": "일",
    "week": "주",
    "month": "월",
    "year": "년",
    "emptyGoals": "목표가 여기에 표시됩니다",
    "addFirst": "+를 눌러 첫 목표 만들기",
    "cancel": "취소",
    "confirm": "확인"
  },
  "ja": {
    "settings": "設定",
    "personalization": "パーソナライズ",
    "language": "言語",
    "data": "データ管理",
    "resetProgress": "進捗をリセット",
    "resetSubtitle": "XP、タスク、活動、記録を削除",
    "deleteAccount": "アカウントを削除",
    "deleteSubtitle": "ローカルプロフィールと進捗を削除",
    "information": "情報",
    "privacy": "プライバシー",
    "privacySubtitle": "データの保存と利用方法",
    "about": "アプリについて",
    "aboutSubtitle": "バージョン、目的、お問い合わせ",
    "languageTitle": "アプリの言語",
    "languageSaved": "アプリの言語を変更しました。",
    "goals": "目標",
    "active": "件進行中",
    "day": "日",
    "week": "週",
    "month": "月",
    "year": "年",
    "emptyGoals": "ここに目標が表示されます",
    "addFirst": "+を押して最初の目標を作成",
    "cancel": "キャンセル",
    "confirm": "確認"
  },
  "hi": {
    "settings": "सेटिंग्स",
    "personalization": "वैयक्तिकरण",
    "language": "भाषा",
    "data": "डेटा प्रबंधन",
    "resetProgress": "प्रगति रीसेट करें",
    "resetSubtitle": "XP, कार्य, गतिविधि और प्रविष्टियाँ हटाएँ",
    "deleteAccount": "खाता हटाएँ",
    "deleteSubtitle": "स्थानीय प्रोफ़ाइल और प्रगति हटाएँ",
    "information": "जानकारी",
    "privacy": "गोपनीयता",
    "privacySubtitle": "डेटा कैसे संग्रहीत और उपयोग होता है",
    "about": "ऐप के बारे में",
    "aboutSubtitle": "संस्करण, उद्देश्य और संपर्क",
    "languageTitle": "ऐप की भाषा",
    "languageSaved": "ऐप की भाषा बदल दी गई है।",
    "goals": "मेरे लक्ष्य",
    "active": "सक्रिय",
    "day": "दिन",
    "week": "सप्ताह",
    "month": "महीना",
    "year": "वर्ष",
    "emptyGoals": "आपके लक्ष्य यहाँ दिखाई देंगे",
    "addFirst": "पहला लक्ष्य बनाने के लिए + दबाएँ",
    "cancel": "रद्द करें",
    "confirm": "पुष्टि करें"
  },
  "ar": {
    "settings": "الإعدادات",
    "personalization": "التخصيص",
    "language": "اللغة",
    "data": "إدارة البيانات",
    "resetProgress": "إعادة ضبط التقدم",
    "resetSubtitle": "حذف XP والمهام والنشاط والسجلات",
    "deleteAccount": "حذف الحساب",
    "deleteSubtitle": "حذف الملف الشخصي والتقدم المحلي",
    "information": "معلومات",
    "privacy": "الخصوصية",
    "privacySubtitle": "كيفية تخزين البيانات واستخدامها",
    "about": "حول التطبيق",
    "aboutSubtitle": "الإصدار والهدف وطرق التواصل",
    "languageTitle": "لغة التطبيق",
    "languageSaved": "تم تغيير لغة التطبيق.",
    "goals": "أهدافي",
    "active": "نشطة",
    "day": "يوم",
    "week": "أسبوع",
    "month": "شهر",
    "year": "سنة",
    "emptyGoals": "ستظهر أهدافك هنا",
    "addFirst": "اضغط + لإنشاء هدفك الأول",
    "cancel": "إلغاء",
    "confirm": "تأكيد"
  },
  "tr": {
    "settings": "Ayarlar",
    "personalization": "KİŞİSELLEŞTİRME",
    "language": "Dil",
    "data": "VERİ YÖNETİMİ",
    "resetProgress": "İlerlemeyi sıfırla",
    "resetSubtitle": "XP, görevler, etkinlik ve kayıtları sil",
    "deleteAccount": "Hesabı sil",
    "deleteSubtitle": "Yerel profili ve ilerlemeyi sil",
    "information": "BİLGİ",
    "privacy": "Gizlilik",
    "privacySubtitle": "Verilerin saklanması ve kullanılması",
    "about": "Uygulama hakkında",
    "aboutSubtitle": "Sürüm, amaç ve iletişim",
    "languageTitle": "UYGULAMA DİLİ",
    "languageSaved": "Uygulama dili değiştirildi.",
    "goals": "Hedeflerim",
    "active": "aktif",
    "day": "Gün",
    "week": "Hafta",
    "month": "Ay",
    "year": "Yıl",
    "emptyGoals": "Hedeflerin burada görünecek",
    "addFirst": "İlk hedefini oluşturmak için + düğmesine bas",
    "cancel": "İptal",
    "confirm": "Onayla"
  },
  "tk": {
    "settings": "Sazlamalar",
    "personalization": "ŞAHsyLAŞDYRMA",
    "language": "Dil",
    "data": "MAGLUMATLARY DOLANDYRMAK",
    "resetProgress": "Öňe gidişi täzeden başlat",
    "resetSubtitle": "XP, wezipeleri, işjeňligi we ýazgylary poz",
    "deleteAccount": "Hasaby pozmak",
    "deleteSubtitle": "Ýerli profili we öňe gidişi poz",
    "information": "MAGLUMAT",
    "privacy": "Gizlinlik",
    "privacySubtitle": "Maglumatlaryň saklanyşy we ulanylyşy",
    "about": "Programma barada",
    "aboutSubtitle": "Wersiýa, maksat we habarlaşmak",
    "languageTitle": "PROGRAMMANYŇ DILI",
    "languageSaved": "Programmanyň dili üýtgedildi.",
    "goals": "Maksatlarym",
    "active": "işjeň",
    "day": "Gün",
    "week": "Hepde",
    "month": "Aý",
    "year": "Ýyl",
    "emptyGoals": "Maksatlaryň şu ýerde görkeziler",
    "addFirst": "Ilkinji maksady döretmek üçin + bas",
    "cancel": "Ýatyr",
    "confirm": "Tassykla"
  }
};


const Map<String, Map<String, String>> _navigationTranslations = {
  "ru": {
    "navHome": "Главная",
    "navDevelopment": "Развитие",
    "navResources": "Ресурсы",
    "navProgress": "Прогресс",
    "navProfile": "Профиль",
    "shellSubtitle": "Система дисциплины и целей",
    "widgets": "Виджеты",
    "notifications": "Уведомления",
    "notificationsSoon": "Уведомления появятся в одном из следующих обновлений."
  },
  "uk": {
    "navHome": "Головна",
    "navDevelopment": "Розвиток",
    "navResources": "Ресурси",
    "navProgress": "Прогрес",
    "navProfile": "Профіль",
    "shellSubtitle": "Система дисципліни та цілей",
    "widgets": "Віджети",
    "notifications": "Сповіщення",
    "notificationsSoon": "Сповіщення з’являться в одному з наступних оновлень."
  },
  "en": {
    "navHome": "Home",
    "navDevelopment": "Development",
    "navResources": "Resources",
    "navProgress": "Progress",
    "navProfile": "Profile",
    "shellSubtitle": "A system for discipline and goals",
    "widgets": "Widgets",
    "notifications": "Notifications",
    "notificationsSoon": "Notifications will arrive in a future update."
  },
  "fr": {
    "navHome": "Accueil",
    "navDevelopment": "Développement",
    "navResources": "Ressources",
    "navProgress": "Progrès",
    "navProfile": "Profil",
    "shellSubtitle": "Un système de discipline et d’objectifs",
    "widgets": "Widgets",
    "notifications": "Notifications",
    "notificationsSoon": "Les notifications arriveront dans une prochaine mise à jour."
  },
  "de": {
    "navHome": "Start",
    "navDevelopment": "Entwicklung",
    "navResources": "Ressourcen",
    "navProgress": "Fortschritt",
    "navProfile": "Profil",
    "shellSubtitle": "Ein System für Disziplin und Ziele",
    "widgets": "Widgets",
    "notifications": "Benachrichtigungen",
    "notificationsSoon": "Benachrichtigungen folgen in einem zukünftigen Update."
  },
  "es": {
    "navHome": "Inicio",
    "navDevelopment": "Desarrollo",
    "navResources": "Recursos",
    "navProgress": "Progreso",
    "navProfile": "Perfil",
    "shellSubtitle": "Un sistema de disciplina y objetivos",
    "widgets": "Widgets",
    "notifications": "Notificaciones",
    "notificationsSoon": "Las notificaciones llegarán en una próxima actualización."
  },
  "zh": {
    "navHome": "主页",
    "navDevelopment": "成长",
    "navResources": "资源",
    "navProgress": "进度",
    "navProfile": "个人资料",
    "shellSubtitle": "自律与目标管理系统",
    "widgets": "小组件",
    "notifications": "通知",
    "notificationsSoon": "通知功能将在后续更新中推出。"
  },
  "ko": {
    "navHome": "홈",
    "navDevelopment": "성장",
    "navResources": "자료",
    "navProgress": "진행",
    "navProfile": "프로필",
    "shellSubtitle": "규율과 목표 관리 시스템",
    "widgets": "위젯",
    "notifications": "알림",
    "notificationsSoon": "알림 기능은 추후 업데이트에서 제공됩니다."
  },
  "ja": {
    "navHome": "ホーム",
    "navDevelopment": "成長",
    "navResources": "リソース",
    "navProgress": "進捗",
    "navProfile": "プロフィール",
    "shellSubtitle": "規律と目標のためのシステム",
    "widgets": "ウィジェット",
    "notifications": "通知",
    "notificationsSoon": "通知機能は今後のアップデートで追加されます。"
  },
  "hi": {
    "navHome": "होम",
    "navDevelopment": "विकास",
    "navResources": "संसाधन",
    "navProgress": "प्रगति",
    "navProfile": "प्रोफ़ाइल",
    "shellSubtitle": "अनुशासन और लक्ष्यों की प्रणाली",
    "widgets": "विजेट",
    "notifications": "सूचनाएँ",
    "notificationsSoon": "सूचनाएँ भविष्य के अपडेट में उपलब्ध होंगी।"
  },
  "ar": {
    "navHome": "الرئيسية",
    "navDevelopment": "التطوير",
    "navResources": "الموارد",
    "navProgress": "التقدم",
    "navProfile": "الملف الشخصي",
    "shellSubtitle": "نظام للانضباط والأهداف",
    "widgets": "الأدوات",
    "notifications": "الإشعارات",
    "notificationsSoon": "ستتوفر الإشعارات في تحديث قادم."
  },
  "tr": {
    "navHome": "Ana Sayfa",
    "navDevelopment": "Gelişim",
    "navResources": "Kaynaklar",
    "navProgress": "İlerleme",
    "navProfile": "Profil",
    "shellSubtitle": "Disiplin ve hedef sistemi",
    "widgets": "Bileşenler",
    "notifications": "Bildirimler",
    "notificationsSoon": "Bildirimler gelecek güncellemelerden birinde sunulacak."
  },
  "tk": {
    "navHome": "Baş sahypa",
    "navDevelopment": "Ösüş",
    "navResources": "Çeşmeler",
    "navProgress": "Öňe gidiş",
    "navProfile": "Profil",
    "shellSubtitle": "Düzgün-nyzam we maksatlar ulgamy",
    "widgets": "Widjetler",
    "notifications": "Bildirişler",
    "notificationsSoon": "Bildirişler geljekki täzelenmeleriň birinde goşular."
  }
};
