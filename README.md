# BFinance

BFinance is a personal finance and expense-tracking mobile application built with **Flutter** and **Django REST Framework**.

The application helps users manage their income and expenses, organize transactions by category, manage budgets, and analyze their financial activity.

## Features

- User registration and login
- JWT-based authentication
- Expense and income management
- Custom and default categories
- Budget management
- Budget alerts and local notifications
- Spending analytics
- Currency selection and exchange-rate conversion
- Password reset via email OTP
- Persistent user authentication
- Secure token storage
- Error monitoring with Sentry

## Tech Stack

### Mobile

- Flutter
- Dart
- Provider
- Flutter Secure Storage
- SharedPreferences
- Local Notifications
- Currency Picker

### Backend

- Python
- Django
- Django REST Framework
- PostgreSQL
- JWT Authentication

### Deployment & Tools

- Render — Backend deployment
- Supabase — PostgreSQL database hosting
- Git / Github
- Sentry
- Docker


## Screenshots

<h3>Dashboard</h3>

<img src="assets/screenshots/dashboard.png" alt="Dashboard" width="250">

<h3>Analytics</h3>

<img src="assets/screenshots/analytics.png" alt="Analytics" width="250">

<h3>Budget Limit</h3>

<img src="assets/screenshots/budget_limit.png" alt="Budget" width="250">

<h3>Change Currency</h3>

<img src="assets/screenshots/currency.png" alt="Change Currency" width="250">


## Architecture & Deployment

The application uses the following deployment setup:

```text
Flutter Mobile App
        |
        | HTTPS / REST API
        v
    Render
(Django REST Framework)
        |
        v
Supabase
(PostgreSQL)
```
Django Backend -> Render

The Django REST API is deployed on Render, while the PostgreSQL database is hosted on Supabase.

## Project Structure

```text
bfinance/
├── Flutter mobile application
└── Django REST API backend
```

## Status

The application is currently under development and is available for Closed Testing through Google Play.
## Author

**Arjun Uchai Thakuri**

- GitHub: [GitHub Profile](https://github.com/binayuchai)
