import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';

class VirilStoreScreen extends StatelessWidget {
  const VirilStoreScreen({super.key});
  static const _items = <_StoreItem>[
    _StoreItem('theme_midnight', 'Тема «Полночь»', 'Новая цветовая атмосфера приложения', Icons.dark_mode_rounded, 40, 'ОФОРМЛЕНИЕ'),
    _StoreItem('theme_ice', 'Тема «Ледяной импульс»', 'Холодные оттенки и акценты', Icons.ac_unit_rounded, 55, 'ОФОРМЛЕНИЕ'),
    _StoreItem('profile_frame_gold', 'Золотая рамка', 'Особое оформление аватара', Icons.crop_square_rounded, 35, 'ПРОФИЛЬ'),
    _StoreItem('avatar_pack', 'Набор символов', 'Дополнительные варианты аватара', Icons.face_retouching_natural_rounded, 50, 'ПРОФИЛЬ'),
    _StoreItem('quote_pack', 'Пакет цитат', 'Подборка фраз для личного профиля', Icons.format_quote_rounded, 20, 'ПРОФИЛЬ'),
    _StoreItem('focus_pack', 'Фокус-сессии', 'Набор сценариев для спокойной концентрации', Icons.center_focus_strong_rounded, 45, 'ПОЛЕЗНЫЕ МАТЕРИАЛЫ'),
    _StoreItem('reading_pack', 'Мини-гид по чтению', 'Идеи, как выстроить регулярное чтение', Icons.menu_book_rounded, 30, 'ПОЛЕЗНЫЕ МАТЕРИАЛЫ'),
    _StoreItem('reset_pack', 'Перезагрузка', 'Небольшие идеи для отдыха и восстановления', Icons.spa_rounded, 25, 'ПОЛЕЗНЫЕ МАТЕРИАЛЫ'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Магазин')),
    body: AnimatedBuilder(animation: VirilStore.instance, builder: (context, _) {
      final store = VirilStore.instance;
      return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
        _balanceCard(store.vcoins),
        const SizedBox(height: 18),
        const Text('НАГРАДЫ ЗА ТВОЙ ПРОГРЕСС', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('Получай V-Coin за выполненные цели и привычки. Это внутренняя игровая валюта Viril: она не имеет денежной стоимости и не обменивается на деньги.', style: TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.45)),
        const SizedBox(height: 18),
        for (final category in ['ОФОРМЛЕНИЕ', 'ПРОФИЛЬ', 'ПОЛЕЗНЫЕ МАТЕРИАЛЫ']) ...[
          Padding(padding: const EdgeInsets.only(bottom: 9, top: 4), child: Text(category, style: const TextStyle(color: VirilColors.ice, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900))),
          for (final item in _items.where((item) => item.category == category)) _itemCard(context, store, item),
          const SizedBox(height: 9),
        ],
      ]);
    }),
  );
  Widget _balanceCard(int balance) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF34302A), Color(0xFF171A20), Color(0xFF10141B)]), border: Border.all(color: VirilColors.gold.withValues(alpha: .48)), boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 16, offset: Offset(0, 7))]),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: VirilColors.gold.withValues(alpha: .14), border: Border.all(color: VirilColors.gold.withValues(alpha: .7))), child: const Icon(Icons.toll_rounded, color: VirilColors.gold, size: 27)),
      const SizedBox(width: 13),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ТВОЙ БАЛАНС', style: TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w800)), SizedBox(height: 3), Text('V-Coin', style: TextStyle(color: VirilColors.gold, fontSize: 17, fontWeight: FontWeight.w900))])),
      Text('$balance', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
    ]),
  );
  Widget _itemCard(BuildContext context, VirilStore store, _StoreItem item) {
    final owned = store.ownsStoreItem(item.id);
    final affordable = store.vcoins >= item.price;
    return Container(
      margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(16), border: Border.all(color: owned ? VirilColors.ice.withValues(alpha: .4) : VirilColors.line)),
      child: Row(children: [
        Container(width: 43, height: 43, decoration: BoxDecoration(color: VirilColors.gold.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(item.icon, color: VirilColors.gold, size: 23)),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3), Text(item.description, style: const TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.35)),
          const SizedBox(height: 6), Row(children: [const Icon(Icons.toll_rounded, color: VirilColors.gold, size: 13), const SizedBox(width: 3), Text('${item.price} V-Coin', style: const TextStyle(color: VirilColors.gold, fontSize: 10, fontWeight: FontWeight.w800))]),
        ])),
        const SizedBox(width: 7),
        SizedBox(height: 34, child: owned
          ? const Chip(label: Text('Открыто'), visualDensity: VisualDensity.compact, side: BorderSide.none)
          : FilledButton(onPressed: affordable ? () async {
              final success = await store.purchaseStoreItem(item.id, item.price);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Предмет добавлен в твои покупки.' : 'Недостаточно V-Coin.')));
            } : null, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)), child: const Text('Открыть', style: TextStyle(fontSize: 10)))),
      ]),
    );
  }
}
class _StoreItem {
  const _StoreItem(this.id, this.title, this.description, this.icon, this.price, this.category);
  final String id, title, description, category;
  final IconData icon;
  final int price;
}
