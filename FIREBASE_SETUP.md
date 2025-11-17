# Firebase Firestore Configuration Guide

## Обзор
Приложение теперь синхронизирует все данные с Firebase Firestore, включая:
- Профили пользователей
- Статистику и прогресс
- Челленджи (личные и публичные)
- Записи в журнале
- Историю сессий
- Таблицу лидеров

## Шаг 1: Настройка Firestore в Firebase Console

1. Откройте [Firebase Console](https://console.firebase.google.com/project/rawdogapp-403a2)
2. Перейдите в раздел **Firestore Database**
3. Нажмите **Create database**
4. Выберите режим:
   - **Production mode** (рекомендуется для релиза)
   - **Test mode** (для разработки - открытый доступ на 30 дней)

5. Выберите регион (рекомендуется ближайший к вашим пользователям)

## Шаг 2: Настройка правил безопасности

Перейдите во вкладку **Rules** и замените правила на следующие:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Правила для коллекции пользователей
    match /users/{userId} {
      // Пользователь может читать и писать только свои данные
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Подколлекции пользователя
      match /challenges/{challengeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /journal/{entryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /sessions/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /stats/{statsId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /dailyHistory/{dateId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Публичные челленджи доступны всем для чтения
    match /publicChallenges/{challengeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                      (request.resource.data.keys().hasOnly(['usersCompletedCount']) ||
                       resource.data.creatorId == request.auth.uid);
      allow delete: if request.auth != null && resource.data.creatorId == request.auth.uid;
    }
    
    // Таблица лидеров доступна всем для чтения
    match /leaderboard/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Шаг 3: Создание индексов (опционально)

Для оптимизации запросов создайте следующие составные индексы:

1. Перейдите в **Indexes** → **Composite**
2. Создайте индексы:

### Индекс для publicChallenges
- Collection: `publicChallenges`
- Fields:
  - `usersCompletedCount` (Descending)
  - `createdAt` (Descending)

### Индекс для leaderboard
- Collection: `leaderboard`
- Fields:
  - `totalPoints` (Descending)
  - `lastUpdated` (Descending)

### Индекс для dailyHistory
- Collection Group: `dailyHistory`
- Fields:
  - `date` (Ascending)

## Структура базы данных

### users/{userId}
```
{
  userName: string,
  email: string,
  createdAt: timestamp,
  lastUpdated: timestamp
}
```

#### users/{userId}/stats/current
```
{
  dailyStreak: number,
  totalRawTime: number (seconds),
  totalPoints: number,
  dailyGoalMinutes: number,
  lastUpdated: timestamp
}
```

#### users/{userId}/challenges/{challengeId}
```
{
  title: string,
  durationMinutes: number,
  isCompleted: boolean,
  isPublic: boolean,
  createdAt: timestamp,
  usersCompletedCount: number
}
```

#### users/{userId}/journal/{entryId}
```
{
  date: timestamp,
  duration: number (seconds),
  thoughts: string
}
```

#### users/{userId}/sessions/{sessionId}
```
{
  startTime: timestamp,
  endTime: timestamp,
  duration: number (seconds)
}
```

#### users/{userId}/dailyHistory/{dateString}
```
{
  date: timestamp,
  totalMinutes: number
}
```

### publicChallenges/{challengeId}
```
{
  title: string,
  durationMinutes: number,
  creatorId: string,
  usersCompletedCount: number,
  createdAt: timestamp
}
```

### leaderboard/{userId}
```
{
  nickname: string,
  totalRawTime: number (seconds),
  totalPoints: number,
  lastUpdated: timestamp
}
```

## Как работает синхронизация

### Автоматическая синхронизация
Приложение автоматически синхронизируется с Firebase в следующих случаях:
1. **При входе пользователя** - загружаются все данные пользователя
2. **После завершения сессии** - сохраняется сессия и обновляется статистика
3. **При создании/изменении челленджа** - сохраняется челлендж
4. **При сохранении записи в журнале** - сохраняется запись
5. **При изменении статистики** - обновляется таблица лидеров

### Ручная синхронизация
Для принудительной синхронизации:
```swift
appState.saveToFirebase()
```

### Загрузка данных при входе
При успешной авторизации автоматически вызывается:
```swift
appState.setUser(userId: user.uid, userName: displayName, email: user.email)
```

Это запускает полную синхронизацию:
- Создается/обновляется профиль пользователя
- Загружаются все челленджи
- Загружается статистика
- Загружаются записи журнала
- Загружается история активности
- Загружаются публичные челленджи
- Загружается таблица лидеров

## Индикатор загрузки

Во время синхронизации пользователь видит overlay с индикатором загрузки:
- `appState.isLoading` автоматически управляет отображением
- Показывается во время начальной загрузки данных
- Не блокирует фоновые операции сохранения

## Миграция существующих пользователей

Если у вас есть пользователи с локальными данными:
1. При первом входе после обновления их данные автоматически загрузятся с сервера
2. Локальные данные будут заменены серверными
3. Для сохранения локальных данных реализуйте логику миграции в `setUser()`

## Тестирование

### Test Mode (для разработки)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 17);
    }
  }
}
```

### Production Mode
Используйте правила из Шага 2 для продакшена.

## Мониторинг

1. В Firebase Console перейдите в **Firestore Database**
2. Вкладка **Usage** - отслеживайте количество операций чтения/записи
3. Вкладка **Data** - просматривайте данные в реальном времени

## Лимиты бесплатного плана

- Хранилище: 1 GB
- Чтение документов: 50,000 в день
- Запись документов: 20,000 в день
- Удаление документов: 20,000 в день

При превышении лимитов необходимо перейти на платный план Blaze.

## Поддержка оффлайн режима

Firestore автоматически кэширует данные:
- Приложение работает оффлайн
- При восстановлении соединения данные синхронизируются автоматически
- Конфликты разрешаются по принципу "последний запись побеждает"
