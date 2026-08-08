# 📒 Sivvai Bookkeeper — Full Product Documentation

> **Version:** 1.0.0 &nbsp;|&nbsp; **Platform:** Android, iOS, Linux, macOS, Windows, Web &nbsp;|&nbsp; **Language:** Dart / Flutter

---

## 1. Overview

**Sivvai Bookkeeper** is a premium, minimalist mobile ledger application built for small businesses, micro-merchants, market traders, freelancers, and anyone who manages daily cash flow without a full accounting team. It replaces messy paper registers and complex accounting software with a clean, fast, and intelligent digital wallet.

The app focuses on the three core financial activities every small business owner deals with every day:

1. **Recording cash in & cash out** (sales and expenses)
2. **Tracking who owes you money and who you owe** (ledger / debt management)
3. **Staying financially aware** through real-time dashboards, analytics, and exportable reports

The currency is Nigerian Naira (₦), making it specifically tailored for the Nigerian small business market, though the underlying system is currency-agnostic by design.

---

## 2. Who Can Use It

| User Type | How They Benefit |
|---|---|
| **Market traders / vendors** | Quickly log daily sales and expenses; track customers who buy on credit |
| **Small shop owners** | Manage stock-paid-on-credit (debtors) and suppliers owed (creditors) |
| **Freelancers & service providers** | Track client invoices, partial payments, and outstanding balances |
| **Personal finance managers** | Manage household income, expenses, and money lent to/borrowed from others |
| **Micro-business owners** | Separate financial records per business using the multi-profile system |
| **Small-scale entrepreneurs** | Monitor business health with analytics and shareable financial reports |

---

## 3. Key Features

### 3.1 📊 Home Dashboard
The first screen the user sees after login. It provides a full financial snapshot at a glance.

- **Cash in Hand Card** — A branded gradient card (emerald-to-cyan-to-blue) displaying the total liquid cash balance in real time.
- **Sales / Expenses / Debt Summary Row** — Three quick-glance metrics: total sales, total expenses, and total outstanding debt.
- **Date Filter Chips** — Filter the dashboard view by: `All Time`, `Today`, `This Week`, `This Month`.
- **Transaction Type Filter** — A popup filter to narrow the recent list to: `Sales Only`, `Expenses Only`, `Debts & Payments`, or `Show All`.
- **Recent Transactions List** — The last 10 transactions, colour-coded by type (green for income, red for expense, amber for credit/debt), with icons and amounts.
- **Pull-to-Refresh** — Swipe down anywhere on the scrollable area to force a data reload.
- **Profile Switcher Pill** — Tap the pill button (top-left) to switch between profiles instantly.
- **Settings Shortcut** — A gear icon (top-right) links directly to the Settings screen.

---

### 3.2 ➕ Add / Edit Transactions
The core data entry screen, accessible via a floating action button (modal bottom sheet) or as a full page when editing.

#### Transaction Types
| Type | What it means |
|---|---|
| **Sale / Income (INFLOW)** | Cash received — a sale, payment received, income |
| **Expense (OUTFLOW)** | Cash paid out — a purchase, bill, operational cost |

#### Credit Toggle
Each transaction can optionally be flagged as **"on credit"**, converting it from a cash movement to a ledger entry:

- **Sale on Credit** → Goods or services provided but not yet paid for. The buyer becomes a **Debtor**.
- **Expense on Credit** → Goods or services received but not yet paid for. The supplier becomes a **Creditor**.

#### Customer / Contact Selector
When credit is enabled, an autocomplete search field appears to link the transaction to an existing contact or create a new one on the spot, complete with phone number capture.

#### Built-in Calculator
A full-screen calculator widget is accessible via the calculator icon next to the amount field — useful for computing totals before entering them.

#### Remarks Field
A free-text field for labelling what the transaction was for (e.g. "Fabric purchase", "Client invoice #12", "Rent").

#### Smart Validation & Overpayment Guard
When logging a **repayment** for a contact with an active balance:
1. The app detects the opposing direction (e.g. a debtor receiving an outflow entry).
2. It prompts whether this is a **settlement** or a **separate new record**.
3. If the entered amount **exceeds the outstanding balance**, an alert is shown with the exact outstanding amount and a one-click option to auto-fill the correct figure.

#### Edit & Delete
Any existing transaction can be tapped from the history to edit its amount and remarks, or permanently deleted (with confirmation). Deleting a transaction automatically recalculates all balances.

---

### 3.3 📖 Debt Ledger (Ledger Management)
A dedicated screen for managing credit-based relationships, split into two tabs:

#### Tab 1: "Money to Collect" (Debtors)
- Lists all contacts who owe the user money.
- Shows the contact name, phone number, and outstanding balance.
- Displays a summary header with the **total owed to you**.

#### Tab 2: "Money to Pay" (Creditors)
- Lists all contacts the user owes money to.
- Shows the contact name, phone number, and balance due.
- Displays a summary header with the **total you owe**.

#### Contact Actions (Bottom Sheet)
Tapping any contact on the ledger opens an action sheet with:

| Action | Description |
|---|---|
| **Settle Balance** | Opens a repayment dialog to log a full or partial payment against the balance |
| **Transaction History** | Opens a filtered view of all transactions linked to this contact |
| **Edit Contact** | Rename the contact or update their phone number |
| **Delete Contact** | Removes the contact from the ledger (transaction history is preserved for accounting accuracy) |
| **Send WhatsApp Reminder** | (Debtors only) — Composes a pre-filled payment reminder message via WhatsApp or the native share sheet |

#### Dynamic Ledger Role Transition
The most sophisticated feature: when a contact's net balance reaches **zero** after a repayment, the app automatically reassigns their role (Debtor ↔ Creditor) if new transactions push them to the other side. This eliminates manual contact management.

---

### 3.4 📜 Global History
A complete, paginated log of every transaction ever recorded in the active profile.

- **Real-time stream** — Built on Isar database watchers; the list updates live without manual refresh.
- **Date filters** — `All`, `Today`, `This Week`, `This Month`.
- **Type filters** — `Show All`, `Sales Only`, `Expenses Only`, `Debts & Payments`.
- **Transaction Cards** — Show type icon, title/remarks, contact name (if linked), date/time, and amount with +/− colour coding.
- **Interactive Actions** — Tapping any transaction opens an action bottom sheet with **Edit** and **Delete Permanently** options.
- **Deep-link scroll** — When tapped from the Home screen, the history can scroll directly to a specific transaction.

---

### 3.5 📈 Financial Analytics
A visual dashboard powered by the `fl_chart` library.

- **Cash Flow Summary Bar Chart** — Compares total sales (green bar) vs total expenses (red bar) side by side.
- **Expense Breakdown Pie Chart** — Groups expenses by their remarks/label into categories, shown with percentage slices and a colour-coded legend (up to 5 categories visible).
- Both charts pull from the currently active profile's live data.

---

### 3.6 👥 Multi-Profile System
The app supports **completely isolated financial profiles** under a single app installation.

- **Create Profiles** — Named profiles (e.g. "Business", "Personal", "Side Hustle") each get their own separate Isar database instance.
- **Switch Profiles** — Tap the profile pill on the Home screen → switch instantly; all data, contacts, and balances are fully isolated.
- **Rename / Delete Profiles** — Full lifecycle management from the Profiles screen.
- **Default Profile** — One profile is always set as the default, auto-loaded on app startup.
- Each profile has its own: transactions, contacts, cash balance, and ledger.

---

### 3.7 📤 Export & Reporting
Generate professional financial reports from Settings → Data & Export.

#### PDF Report includes:
- Branded header with profile name and date range
- **Net Cash Flow Summary** — Actual Cash In, Actual Cash Out, Net Cash Balance
- **Full Transaction Log table** — Date/Time, Contact, Type, Mode/Status, Amount
- **Active Pending Ledger section** — All contacts with non-zero balances, split into Receivables (owed to you) and Payables (you owe)

#### Excel (.xlsx) Report includes:
- **Sheet 1: Cash Flow Statement** — Itemised transaction list + summary totals
- **Sheet 2: Active Pending Ledger** — Contact-level outstanding balances
- Both sheets have summary rows with total receivables and payables

#### Date Range Filter
Before exporting, users can optionally pick a custom date range to scope the report to a specific period.

#### Export Formats
- **PDF only**
- **Excel only**
- **Both formats at once**

All reports are shared via the native OS share sheet (save to files, email, WhatsApp, etc.).

---

### 3.8 ☁️ Cloud Backup & Sync (Google Drive)
A built-in backup system that stores the Isar database file to Google Drive.

| Feature | Detail |
|---|---|
| **Google Sign-In** | Connects a Google account via OAuth |
| **Manual Backup** | "Back Up Now" — uploads the current profile's database file to Google Drive |
| **Auto-Backup** | Automatically backs up when the app is paused (sent to background) or when switching profiles |
| **Restore** | Downloads the latest backup from Google Drive and overwrites local data (with confirmation) |
| **Backup Info** | Shows the last backup date, timestamp, and file size |
| **Sign Out** | Disconnects the Google account while preserving local data |

---

### 3.9 🔒 Security — Biometric App Lock
Protects user data with device biometrics (fingerprint, face ID).

- **Enable/Disable** — A toggle switch in Settings. Automatically grayed out if the device does not support biometrics.
- **Auto-Lock** — If the app is sent to the background for **5 minutes or more**, biometric authentication is required upon resuming.
- **Graceful Fallback** — The lock prompt is non-blocking; if the device doesn't support biometrics, the feature is simply disabled.

---

### 3.10 🎨 Appearance & Theme
- **Light Mode** — Clean white canvas with brand accent colours.
- **Dark Mode** — Deep slate background (`#0F172A`) with bright accents.
- **System Follow** — Automatically matches the device's system theme preference.
- Theme selection is persisted via `shared_preferences` and applied instantly across all screens.

---

### 3.11 📱 Contact Management
A dedicated screen accessible from Ledger Management → Contacts.

- **Full contact list** — All linked contacts with debtor/creditor badge and outstanding balance.
- **Swipe-to-delete** — Swipe left on any contact card for a quick delete with confirmation.
- **Import from Phone** — A button to open the native phone contacts picker and import a contact's name and phone number directly. Requires contacts permission.
- **Edit contacts** — Update name or phone number in-place.

---

### 3.12 📋 Per-Customer Transaction History
- Accessible from the Debt Ledger → any contact → Transaction History.
- Shows every transaction linked to a specific contact.
- Allows understanding the full financial relationship history with a customer or supplier.

---

## 4. Data Architecture

| Layer | Technology |
|---|---|
| **UI Framework** | Flutter (Dart) |
| **Local Database** | Isar (NoSQL, embedded) |
| **State Management** | Provider |
| **Cloud Backup** | Google Drive API via `googleapis` |
| **PDF Generation** | `pdf` package |
| **Excel Generation** | `excel` package |
| **Authentication** | `google_sign_in` |
| **Biometrics** | `local_auth` |
| **Contacts** | `flutter_contacts` |
| **Sharing** | `share_plus` |
| **Theming** | `shared_preferences` for persistence |

### Data Models

#### `LocalTransaction`
| Field | Type | Description |
|---|---|---|
| `id` | `Id` | Auto-incremented primary key |
| `timestamp` | `DateTime` | When the transaction occurred |
| `amount` | `double` | Transaction amount in NGN |
| `transactionType` | `String` | `INFLOW`, `OUTFLOW`, `PAYMENT`, `PAYMENT_IN`, `PAYMENT_OUT` |
| `remarks` | `String?` | Optional label / description |
| `isCredit` | `bool` | Whether this is a credit/debt entry (not immediate cash) |
| `customer` | `IsarLink<LocalCustomer>` | Linked contact (optional) |

#### `LocalCustomer`
| Field | Type | Description |
|---|---|---|
| `id` | `Id` | Auto-incremented primary key |
| `fullName` | `String` | Unique contact name |
| `phoneNumber` | `String?` | Optional phone number |
| `totalDebtAmount` | `double` | Net outstanding balance |
| `relationType` | `String` | `DEBTOR` or `CREDITOR` |
| `lastUsed` | `DateTime?` | Timestamp of last related transaction |

#### `AppProfile`
| Field | Type | Description |
|---|---|---|
| `id` | `Id` | Auto-incremented primary key |
| `name` | `String` | Human-readable profile name |
| `isarName` | `String` | Unique slugified Isar instance name |
| `createdAt` | `DateTime` | Creation timestamp |
| `isDefault` | `bool` | Whether this is the startup profile |

### Balance Calculation Logic
- **Cash Balance** = Sum of all non-credit INFLOW/PAYMENT_IN amounts − Sum of all non-credit OUTFLOW/PAYMENT_OUT amounts
- **Debtor Balance** = Cumulative credit sales to a contact minus payments received
- **Creditor Balance** = Cumulative credit expenses from a contact minus payments made
- Balances are recalculated and saved back to the database on every transaction create/update/delete

---

## 5. App Navigation Structure

```
App
├── Splash Screen
│   └── Biometric Auth (if lock enabled)
│
└── Main Navigation (Bottom Nav)
    ├── 🏠 Home
    │   ├── → Global History (see all)
    │   └── → Settings
    │
    ├── 📖 Ledger Management
    │   ├── Tab: Money to Collect (Debtors)
    │   │   └── → Contact Options Bottom Sheet
    │   │       ├── → Settle Balance Dialog
    │   │       └── → Customer Transaction History
    │   ├── Tab: Money to Pay (Creditors)
    │   │   └── → Contact Options Bottom Sheet
    │   ├── → Global History
    │   └── → Manage Contacts
    │
    ├── 📈 Analytics
    │
    └── [FAB] ➕ New Transaction (Modal Bottom Sheet)
        └── → Calculator Widget
```

---

## 6. Benefits

### 🚀 Speed
- Entries take under 10 seconds from opening to saving.
- The modal bottom sheet for adding transactions means the user never leaves the dashboard.
- An integrated calculator avoids switching between apps.

### 🧠 Intelligence
- The **dynamic ledger role transition** automatically shifts a contact between Debtor and Creditor based on their net balance — eliminating the most common bookkeeping error of creating duplicate contacts.
- The **overpayment guard** prevents accidental over-recording that would corrupt balances.
- The **auto-backup on pause** protects data without requiring the user to remember to back up.

### 🔒 Security
- Biometric lock ensures sensitive financial data is protected even if the phone is shared.
- The 5-minute grace period prevents constant re-authentication while actively using the app.

### 📊 Visibility
- The home dashboard gives an instant financial health check in under 3 seconds.
- The analytics screen helps identify spending patterns and sales performance.
- Export reports make it easy to share records with accountants, partners, or tax authorities.

### 🗂️ Organisation
- Multi-profile isolation is perfect for business owners managing multiple ventures from one phone.
- Each profile is fully independent — no data leakage between profiles.

### 💾 Data Safety
- Google Drive cloud backup means data survives phone loss, factory resets, and device changes.
- Transaction history is always preserved even when contacts are deleted.

---

## 7. Limitations & Scope (v1.0.0)

| Item | Current State |
|---|---|
| **Currency** | Nigerian Naira (₦) only; hardcoded symbol |
| **Analytics** | All-time totals only; no period-based chart filtering yet |
| **Multi-device sync** | Backup/restore only (not real-time sync) |
| **Categories** | Expenses grouped by remarks label (no dedicated category tagging system) |
| **Inventory** | Not included |
| **Invoicing** | Not included |
| **Tax calculations** | Not included |

---

## 8. Setup & Development

### Prerequisites
- Flutter SDK `^3.11.5`
- Dart SDK `^3.11.5`
- Android Studio or VS Code with Flutter extension

### Getting Started

```bash
# Clone the repository
git clone https://github.com/yourusername/sivvai-bookkeeper.git
cd sivvai-bookkeeper

# Install dependencies
flutter pub get

# Generate Isar database code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Key Dependencies

| Package | Purpose |
|---|---|
| `isar` + `isar_flutter_libs` | High-performance local NoSQL database |
| `provider` | Reactive state management |
| `fl_chart` | Analytics charts (bar, pie) |
| `pdf` | PDF report generation |
| `excel` | Excel (.xlsx) report generation |
| `google_sign_in` + `googleapis` | Google Drive cloud backup |
| `local_auth` | Biometric authentication |
| `flutter_contacts` | Phone contacts import |
| `share_plus` | Native OS share sheet |
| `file_picker` | File selection |
| `url_launcher` | WhatsApp deep linking |
| `flutter_native_splash` | Branded splash screen |
| `intl` | Currency & date formatting |
| `shared_preferences` | Theme & settings persistence |
| `permission_handler` | Runtime permissions |

---

## 9. Design Language

The app follows a premium, distraction-free design philosophy:

- **Palette**: Emerald green → Cyan → Deep Blue gradient as the brand identity; slate dark mode background (`#0F172A`)
- **Typography**: Bold, high-contrast text hierarchy with subtle colour-coded status indicators
- **Cards**: Rounded corners (16–24px radius), subtle elevation shadows
- **Status colours**:
  - 🟢 **Inflow / Sales** — Green
  - 🔴 **Outflow / Expense** — Red  
  - 🟡 **Credit / Debt** — Amber/Orange
- **Motion**: Bouncing scroll physics, modal slide-up sheets, smooth navigation transitions
- **Edge-to-edge layout**: No top AppBar; custom padded headers respect the system status bar height

---

*Documentation generated: August 2026 · Sivvai Bookkeeper v1.0.0*
