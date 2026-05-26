# SipSpend

Personal budget and soft-drink tracker for iOS (17+). Track expenses in **EUR**, log soft drinks with **milliliters**, and monitor monthly category budgets.

## Features

- **Home** — balance, monthly spend, weekly soft-drink stats (count, €, ml), budget progress bars
- **Add** — income/expense, categories, ml for drinks, quick “log drink”
- **Activity** — transaction history with swipe to delete
- **Budgets** — monthly EUR limits per category

## Requirements

- macOS with **Xcode 15+** (iOS 17 SDK)
- iPhone simulator or device

## Open in Xcode

### Option A — XcodeGen (recommended)

```bash
brew install xcodegen
cd ~/Projects/SipSpend
xcodegen generate
open SipSpend.xcodeproj
```

Select the **SipSpend** scheme → run on an iPhone simulator (⌘R).

### Option B — Manual Xcode project

1. **File → New → Project** → iOS **App**
2. Product Name: `SipSpend`, Interface **SwiftUI**, Storage **SwiftData**, iOS **17**
3. Save into `~/Projects/SipSpend` (merge with existing `SipSpend/` sources folder)
4. Delete the template `ContentView.swift` if duplicated
5. Drag all files from `SipSpend/` into the target (Models, Views, Utilities, assets)
6. Build and run

## Project layout

```
SipSpend/
  SipSpendApp.swift
  Models/          Account, Category, Transaction
  Views/           Dashboard, Add, Activity, Budgets, RootTabView
  Utilities/       Money, budgets, drinks, seed data, transactions
  Assets.xcassets
```

## Defaults

On first launch, seed data creates:

| Category     | Monthly budget |
|-------------|----------------|
| Soft Drinks | €40            |
| Food        | €300           |
| Transport   | €120           |
| Other       | €100           |

Quick log drink uses **330 ml** and the last amount you saved (default **€2.50**).

## Privacy

All data stays on device (SwiftData). No network or accounts.
