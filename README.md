# Baggage Fee Estimator (ICT602 Assignment)

A Flutter mobile application developed for the UiTM ICT602 (Mobile Technology) course assignment. 

## What does it do?
This application helps estimate the excess baggage fee for air travel. Users can input their baggage weight, select their ticket class (Economy or Business), and enter the excess baggage rate per kilogram. 

Based on the inputs, the app automatically calculates:
- **Excess Baggage Weight**: (Total Baggage Weight - Allowed Weight)
- **Excess Baggage Charge**: (Excess Weight × Rate per kg)
- **Total Amount Payable**: The final price, which includes an 8% service tax applied to the excess charge.

### Allowed Weight Allowances:
- **Economy Class**: 20 kg
- **Business Class**: 40 kg

## Tech Stack
- Flutter
- Dart
