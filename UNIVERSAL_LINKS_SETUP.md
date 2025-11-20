# Universal Links Setup Guide

## Overview
Universal Links позволяют открывать приложение напрямую по HTTPS ссылке. Если приложение не установлено - пользователь попадает на веб-страницу (можно сделать редирект в App Store).

## Current Implementation

### 1. DynamicLinksManager
- Поддерживает и Universal Links (`https://beraw.app/challenge/UUID`) и Custom Scheme (`beraw://challenge/UUID`)
- Метод `createChallengeLink()` теперь возвращает Universal Link
- Автоматически извлекает challenge ID из обоих форматов

### 2. URL Formats
- **Universal Link**: `https://beraw.app/challenge/3FAC5238-411B-4F7A-BA69-D4824AA07377`
  - Работает в браузере, соцсетях, мессенджерах
  - Если приложение установлено → открывает приложение
  - Если не установлено → открывает веб-страницу
- **Custom Scheme**: `beraw://challenge/3FAC5238-411B-4F7A-BA69-D4824AA07377`
  - Работает только если приложение установлено
  - Fallback вариант

## Setup Steps

### Step 1: Choose Your Domain
Варианты:
1. **Свой домен** (например `beraw.app`, `getberaw.com`)
2. **Firebase Hosting** - бесплатный домен `yourapp.web.app`
3. **GitHub Pages** - бесплатный домен `yourusername.github.io/beraw`
4. **Cloudflare Pages** - бесплатный домен

⚠️ **ВАЖНО**: Обновите домен в `DynamicLinksManager.swift`:
```swift
private let universalLinkDomain = "beraw.app" // Замените на ваш домен
```

### Step 2: Update Entitlements
Обновите `RawDogged.entitlements` с вашим доменом:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:beraw.app</string>
</array>
```

Или в Xcode:
1. Target → Signing & Capabilities
2. Add Capability → Associated Domains
3. Add domain: `applinks:beraw.app` (замените на ваш)

### Step 3: Create apple-app-site-association File

Создайте файл `apple-app-site-association` (БЕЗ расширения) со следующим содержимым:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.getcode.BeRaw",
        "paths": ["/challenge/*"]
      }
    ]
  }
}
```

⚠️ **Замените**:
- `TEAM_ID` - ваш Apple Team ID (найдите в Apple Developer Account)
- `com.getcode.BeRaw` - ваш Bundle ID

### Step 4: Host the File

**Вариант A: Firebase Hosting**
1. Установите Firebase CLI: `npm install -g firebase-tools`
2. Создайте `public` папку
3. Поместите файл в `public/.well-known/apple-app-site-association`
4. Deploy: `firebase deploy --only hosting`

**Вариант B: GitHub Pages**
1. Создайте репозиторий `yourusername.github.io`
2. Создайте папку `.well-known`
3. Поместите файл в `.well-known/apple-app-site-association`
4. Commit & Push

**Вариант C: Свой веб-сервер**
Разместите файл по адресу:
```
https://beraw.app/.well-known/apple-app-site-association
```

### Step 5: File Requirements
- Должен быть доступен по HTTPS
- Content-Type: `application/json`
- Без расширения `.json`
- Размер < 128KB

### Step 6: Create Landing Page

Создайте веб-страницу по адресу `https://beraw.app/challenge/[UUID]`:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Join Challenge - Be Raw</title>
    <script>
        // Auto-redirect to App Store if app not installed
        setTimeout(function() {
            window.location.href = "https://apps.apple.com/app/idYOUR_APP_ID";
        }, 2000);
    </script>
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; text-align: center; padding: 50px;">
    <h1>🎯 Join the Challenge</h1>
    <p>Opening Be Raw app...</p>
    <p style="margin-top: 30px;">
        <a href="https://apps.apple.com/app/idYOUR_APP_ID" style="background: black; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px;">
            Download Be Raw
        </a>
    </p>
</body>
</html>
```

⚠️ **Замените** `YOUR_APP_ID` на ваш App Store ID

### Step 7: Test Universal Links

**На реальном устройстве** (Universal Links НЕ работают в симуляторе):

1. Отправьте ссылку себе в Notes/Messages
2. Long press → Open
3. Должно открыться приложение

**Проверка файла:**
```bash
curl https://beraw.app/.well-known/apple-app-site-association
```

**Apple CDN validator:**
https://search.developer.apple.com/appsearch-validation-tool/

## Testing

### Custom Scheme (работает в симуляторе):
```bash
xcrun simctl openurl booted "beraw://challenge/3FAC5238-411B-4F7A-BA69-D4824AA07377"
```

### Universal Link (только реальное устройство):
Отправьте ссылку в Messages/Notes и кликните

## Troubleshooting

### Universal Link не открывает приложение
1. ✅ Проверьте что файл доступен по HTTPS
2. ✅ Проверьте Team ID и Bundle ID в файле
3. ✅ Проверьте Associated Domains в entitlements
4. ✅ Переустановите приложение (система кэширует настройки)
5. ✅ Тестируйте на реальном устройстве, не в симуляторе
6. ✅ Убедитесь что кликаете по ссылке, а не копируете в Safari

### Файл не загружается
- Проверьте HTTPS
- Проверьте путь: `/.well-known/apple-app-site-association`
- Проверьте Content-Type: `application/json`

### Custom Scheme работает, Universal Link нет
- Universal Links требуют реальное устройство
- Первый запуск может требовать время на обновление CDN

## Current Status

✅ Код готов для обработки Universal Links
✅ Custom Scheme работает (протестирован)
⏳ Требуется настройка домена и hosting
⏳ Требуется создание apple-app-site-association файла
⏳ Требуется создание landing page

## Next Steps

1. Выберите домен
2. Создайте apple-app-site-association файл с вашим Team ID
3. Разместите файл на сервере
4. Обновите домен в коде и entitlements
5. Создайте landing page с редиректом в App Store
6. Тестируйте на реальном устройстве
