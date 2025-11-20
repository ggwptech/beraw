# Quick Start - Firebase Hosting Setup

## Я уже создал все необходимые файлы для тебя! ✅

Структура готова:
```
firebase-hosting/
├── firebase.json (конфигурация)
├── README.md (детальная инструкция)
└── public/
    ├── index.html (главная страница)
    ├── challenge/
    │   └── index.html (страница челленджа)
    └── .well-known/
        └── apple-app-site-association (настройки Universal Links)
```

## Быстрая установка (5 минут)

### Шаг 1: Установи Node.js и Firebase CLI

**Вариант A: Скачать Node.js напрямую (проще)**
1. Скачай с https://nodejs.org/ (выбери LTS версию)
2. Установи
3. Открой новый Terminal и проверь:
   ```bash
   node --version
   npm --version
   ```

**Вариант B: Через Homebrew (если есть права)**
```bash
sudo chown -R $(whoami) /opt/homebrew
brew install node
```

### Шаг 2: Установи Firebase CLI
```bash
npm install -g firebase-tools
```

### Шаг 3: Залогинься в Firebase
```bash
firebase login
```
- Откроется браузер для авторизации через Google аккаунт

### Шаг 4: Создай Firebase проект
1. Иди на https://console.firebase.google.com/
2. Нажми "Add project"
3. Назови проект (например "beraw" или "be-raw")
4. Отключи Google Analytics (не нужен)
5. Create project

### Шаг 5: Инициализируй проект
```bash
cd firebase-hosting
firebase init hosting
```

Выбери:
- ✅ Use an existing project → выбери созданный проект
- ✅ What do you want to use as your public directory? → `public` (уже указано)
- ✅ Configure as a single-page app? → **No**
- ✅ Set up automatic builds? → **No**
- ✅ Перезаписать файлы? → **No** (наши файлы уже готовы!)

### Шаг 6: Задеплой!
```bash
firebase deploy --only hosting
```

Через ~30 секунд получишь URL типа:
```
✔  Deploy complete!

Hosting URL: https://beraw-12345.web.app
```

### Шаг 7: Обнови код приложения

**1. DynamicLinksManager.swift** (строка ~15):
```swift
private let universalLinkDomain = "beraw-12345.web.app" // Замени на свой URL
```

**2. RawDogged.entitlements** - замени домен:
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:beraw-12345.web.app</string>
</array>
```

Или через Xcode:
- Target → Signing & Capabilities
- Associated Domains
- Замени на: `applinks:beraw-12345.web.app`

### Шаг 8: Пересобери приложение
1. Clean Build Folder (Cmd+Shift+K)
2. Build (Cmd+B)
3. Переустанови на устройство

## Тестирование

### ⚠️ ВАЖНО: Universal Links работают ТОЛЬКО на реальном устройстве!

**На реальном iPhone:**
1. Отправь себе ссылку в Messages или Notes:
   ```
   https://beraw-12345.web.app/challenge/3FAC5238-411B-4F7A-BA69-D4824AA07377
   ```
2. Кликни на ссылку (НЕ долгое нажатие, просто тап)
3. Должно открыться приложение и показаться челлендж!

**Если приложение не установлено:**
- Откроется красивая landing page
- Через 3 секунды редирект в App Store

## Проверка что всё работает

### 1. Проверь файл доступен:
```bash
curl https://beraw-12345.web.app/.well-known/apple-app-site-association
```
Должен вернуть JSON с твоим Team ID

### 2. Проверь landing page:
Открой в браузере: `https://beraw-12345.web.app/challenge/test`
Должна показаться красивая страница

### 3. Apple CDN validator:
https://search.developer.apple.com/appsearch-validation-tool/
Введи свой домен для проверки

## Troubleshooting

### "Node.js not found"
- Скачай с nodejs.org
- Или исправь права Homebrew: `sudo chown -R $(whoami) /opt/homebrew`

### Universal Link не работает
1. ✅ Тестируешь на реальном устройстве (не симулятор)?
2. ✅ Кликаешь на ссылку (не копируешь в Safari)?
3. ✅ Переустановил приложение после изменения entitlements?
4. ✅ Файл доступен по HTTPS?

### Custom Scheme работает, Universal Link нет
- Это нормально в первые минуты
- Apple CDN кэширует файл, может занять 5-10 минут
- Попробуй переустановить приложение

## Что дальше?

После публикации в App Store:
1. Обнови App Store ID в landing page (`challenge/index.html`)
2. Можешь купить свой домен и подключить к Firebase Hosting
3. Добавь Open Graph теги для красивых превью в соцсетях

## Структура URL

✅ **Universal Link** (работает везде):
```
https://beraw-12345.web.app/challenge/UUID
```

✅ **Custom Scheme** (fallback):
```
beraw://challenge/UUID
```

Оба формата обрабатываются автоматически!
