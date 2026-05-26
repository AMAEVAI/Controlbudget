# Уведомления и виджет SipSpend

## Уведомления (80% / 100%)

- При расходе приложение проверяет каждую категорию с месячным лимитом.
- **80%+** → «Budget almost used»
- **100%+** → «Budget limit reached»
- Одно уведомление на порог **в месяц** для каждой категории (без спама).
- При первом запуске iOS спросит разрешение на уведомления — нажмите **Allow**.

### Проверка

1. В **Budgets** поставьте лимит **Soft Drinks** = `€10`
2. Добавьте расходы на `€8` → должно прийти предупреждение 80%
3. Добавьте ещё `€3` → уведомление о лимите 100%

---

## Виджет «Soft drinks this week»

Показывает за текущую неделю: **Drinks**, **Spent (€)**, **Volume (ml)**.

### Один раз в Xcode (если виджета ещё нет в проекте)

1. Откройте `SipSpend/SipSpend.xcodeproj`
2. **File → New → Target → Widget Extension**
3. Product Name: `SipSpendWidgetExtension`, Include Configuration App Intent: **off**
4. Удалите сгенерированные лишние файлы виджета (если дублируют наши)
5. Добавьте в target **SipSpendWidgetExtension**:
   - `SipSpend/SipSpendWidgetExtension/*`
   - `SipSpend/SipSpend/Shared/AppGroup.swift` (в оба target: app + widget)
7. **Signing & Capabilities** для **SipSpend** и **SipSpendWidgetExtension**:
   - **+ Capability → App Groups**
   - `group.amaev.SipSpend`
8. Entitlements:
   - SipSpend → `SipSpend/SipSpend.entitlements`
   - Extension → `SipSpend/SipSpendWidgetExtension/SipSpendWidgetExtension.entitlements`
9. **SipSpend** target → **General → Frameworks** → Embed **SipSpendWidgetExtension**
10. Run основное приложение, затем на домашнем экране: долгий тап → **Edit Home Screen** → **+** → SipSpend → виджет

### Синхронизация данных

Виджет читает снимок из App Group. Снимок обновляется при каждом добавлении/удалении траты и при открытии приложения.

---

## App Group

Идентификатор: `group.amaev.SipSpend`  
Должен совпадать в entitlements приложения и расширения виджета.
