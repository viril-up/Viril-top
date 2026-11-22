import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/viril_coin.dart';

class VirilStoreScreen extends StatelessWidget {
  const VirilStoreScreen({super.key});

  static const _items = <_StoreItem>[
    _StoreItem('theme_midnight', 'Тема «Полночь»', 'Новая цветовая атмосфера', Icons.dark_mode_rounded, 40, 'ОФОРМЛЕНИЕ'),
    _StoreItem('theme_ice', 'Тема «Ледяной импульс»', 'Холодные оттенки и акценты', Icons.ac_unit_rounded, 55, 'ОФОРМЛЕНИЕ'),
    _StoreItem('profile_frame_gold', 'Золотая рамка', 'Оформление аватара', Icons.crop_square_rounded, 35, 'ПРОФИЛЬ'),
    _StoreItem('avatar_pack', 'Набор символов', 'Дополнительные аватары', Icons.face_retouching_natural_rounded, 50, 'ПРОФИЛЬ'),
    _StoreItem('quote_pack', 'Пакет цитат', 'Фразы для личного профиля', Icons.format_quote_rounded, 20, 'ПРОФИЛЬ'),
    _StoreItem('focus_pack', 'Фокус-сессии', 'Сценарии концентрации', Icons.center_focus_strong_rounded, 45, 'ПОЛЕЗНЫЕ МАТЕРИАЛЫ'),
    _StoreItem('reading_pack', 'Мини-гид по чтению', 'Идеи для регулярного чтения', Icons.menu_book_rounded, 30, 'ПОЛЕЗНЫЕ МАТЕРИАЛЫ'),
    _StoreItem('reset_pack', 'Перезагрузка', 'Идеи для отдыха', Icons.spa_rounded, 25, 'ПОЛЕЗНЫЕ МАТЕРИАЛЫ'),
  ];
  static const _categories = ['ОФОРМЛЕНИЕ', 'ПРОФИЛЬ', 'ПОЛЕЗНЫЕ МАТЕРИАЛЫ'];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Магазин')),
    body: AnimatedBuilder(
      animation: VirilStore.instance,
      builder: (context, _) {
        final store = VirilStore.instance;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          children: [
            _balanceCard(store.vcoins),
            const SizedBox(height: 18),
            const Text('НАГРАДЫ ЗА ТВОЙ ПРОГРЕСС',
              style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            const Text('Получай V-Coin за выполненные цели и привычки. Это внутренняя игровая валюта Viril.',
              style: TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.5)),
            const SizedBox(height: 20),
            for (final category in _categories) ...[
              Row(children: [
                Container(width: 3, height: 16, decoration: BoxDecoration(color: VirilColors.gold, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 9),
                Text(category, style: const TextStyle(color: VirilColors.ice, fontSize: 10, letterSpacing: 1.35, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.where((e) => e.category == category).length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 11, mainAxisSpacing: 11, childAspectRatio: .69,
                ),
                itemBuilder: (context, index) {
                  final items = _items.where((e) => e.category == category).toList();
                  return _itemCard(context, store, items[index]);
                },
              ),
              const SizedBox(height: 20),
            ],
          ],
        );
      },
    ),
  );

  Widget _balanceCard(int balance) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF3A3024), Color(0xFF19212B), Color(0xFF0B1018)]),
      border: Border.all(color: VirilColors.gold.withValues(alpha: .52)),
      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 20, offset: Offset(0, 9))],
    ),
    child: Row(children: [
      const VirilCoin(size: 62),
      const SizedBox(width: 14),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ТВОЙ БАЛАНС', style: TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
        SizedBox(height: 4),
        Text('V-Coin', style: TextStyle(color: VirilColors.gold, fontSize: 19, fontWeight: FontWeight.w900)),
        SizedBox(height: 2),
        Text('Валюта твоего прогресса', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
      ])),
      Text(balance.toString(), style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
    ]),
  );

  Widget _itemCard(BuildContext context, VirilStore store, _StoreItem item) {
    final owned = store.ownsStoreItem(item.id);
    final affordable = store.vcoins >= item.price;
    final accent = owned ? VirilColors.ice : VirilColors.gold;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: owned ? [const Color(0xFF263746), const Color(0xFF141D28)] : [const Color(0xFF302B24), const Color(0xFF171D26), const Color(0xFF10151D)]),
        border: Border.all(color: accent.withValues(alpha: owned ? .42 : .25)),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 11, 10, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Center(child: Container(
            width: 76, height: 76,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [accent.withValues(alpha: .20), VirilColors.navy.withValues(alpha: .35), Colors.transparent])),
            child: Icon(item.icon, color: accent, size: 39),
          ))),
          const SizedBox(height: 5),
          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: VirilColors.text, fontSize: 11, height: 1.2, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: VirilColors.muted, fontSize: 9, height: 1.3)),
          const Spacer(),
          Row(children: [
            const VirilCoin(size: 17, animate: false),
            const SizedBox(width: 4),
            Expanded(child: Text('${item.price} V-Coin', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: VirilColors.gold, fontSize: 10, fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 33,
            child: owned
              ? OutlinedButton(onPressed: null, style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('Открыто', style: TextStyle(fontSize: 10)))
              : FilledButton(
                  onPressed: affordable ? () async {
                    final success = await store.purchaseStoreItem(item.id, item.price);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Предмет добавлен в твои покупки.' : 'Недостаточно V-Coin.')));
                  } : null,
                  style: FilledButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: VirilColors.gold,
                    foregroundColor: const Color(0xFF17130D), disabledBackgroundColor: VirilColors.line,
                    disabledForegroundColor: VirilColors.subdued,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                  child: const Text('Купить', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          ),
        ]),
      ),
    );
  }
}

class _StoreItem {
  const _StoreItem(this.id, this.title, this.description, this.icon, this.price, this.category);
  final String id, title, description, category;
  final IconData icon;
  final int price;
}
