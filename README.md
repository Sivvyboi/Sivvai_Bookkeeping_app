Sivvai Bookkeeper

Sivvai Bookkeeper is a premium, minimalist mobile ledger application built specifically for small businesses and micro-merchants. It simplifies daily financial tracking by replacing messy paper registers with a clean, fast, and intelligent digital wallet.

🚀 Key Features

Dynamic Ledger Transitions: Say goodbye to rigid customer roles. The app features fluid contact profiles that automatically shift between "Money to Collect" (Debtor) and "Money to Pay" (Creditor) views as their net balance naturally crosses zero.

Smart Validation Guardrails: Proactive error prevention intercepts inputs that exceed outstanding balances. If an overpayment is detected, an intelligent alert displays the exact balance and offers a one-click auto-fill option to settle the record cleanly.

Real-Time Cash Flow Sync: Every single transaction logged instantly synchronizes with your global "Cash at Hand" calculations. Your digital wallet always matches your physical cash box in real time.

Minimalist UI/UX: A premium, distraction-free interface engineered to reduce data entry friction, letting busy business owners focus on running their business rather than navigating complex accounting clutter.

🛠️ Tech Stack

Framework: Flutter

Programming Language: Dart

Local Database: Isar (NoSQL)

State Management: Provider

📦 Getting Started

Prerequisites

Make sure you have the Flutter SDK installed on your machine.

Installation

Clone the repository:

git clone https://github.com/yourusername/sivvai-bookkeeper.git
cd sivvai-bookkeeper


Install the dependencies:

flutter pub get


Run the build runner (required for Isar database code generation):

flutter pub run build_runner build --delete-conflicting-outputs


Launch the application:

flutter run


📸 Architecture Insights

The app leverages Isar for high-performance, asynchronous local data storage. Calculations treat inflows/sales as positive boundaries and outflows/expenses/payments as negative boundaries. This mathematical core drives both the dynamic ledger assignment and the instant liquid balance state updates automatically.
