# hrishikesh

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Usage Access Permission

This application reads app usage statistics on Android devices. Android
requires users to manually grant the **Usage Access** permission before any
usage data can be retrieved. If this permission is not granted you may see log
messages similar to:

```
W/UsageStatsHelper: No usage data found. Is permission granted?
```

When launching the app for the first time you will be redirected to the
"Usage Access" settings screen. Locate **hrishikesh** in that list and toggle
**Allow usage access** to **ON**. Once enabled, restart the app and usage data
should start appearing in the logs (for example:
`UsageStatsHelper: Fetched 25 usage entries`).

## Installed Apps View

The home screen now features a **+** button that opens a new page
displaying all user installed applications on the device. System
packages are excluded automatically, while all other apps - including
preinstalled Google applications - are listed. Applications without a
launcher icon are shown using a default Android symbol. Apps are
grouped into the following categories:

- Entertainment
- Gaming
- Education
- Social
- Other

Social apps include popular messengers such as **WhatsApp**, **Telegram**,
**Instagram**, and **LinkedIn**. Entertainment covers streaming services like
**Hotstar**, **Netflix**, and similar apps.
