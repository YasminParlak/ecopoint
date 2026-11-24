# ♻️ EcoPoint — карта пунктов приёма вторсырья

Мобильное приложение для поиска ближайших пунктов сбора вторичного сырья
в Миассе и Златоусте: интерактивная карта, актуальный статус «открыто/закрыто»,
поиск, фильтры и построение маршрута до пункта.

## 🚀 Функционал
- **Карта Яндекс.Карт (MapKit)** с маркерами: 🟢 открыто, 🔴 закрыто
- **Поиск** по названию, адресу и типу отходов
- **Фильтры** по типам отходов (пластик, стекло, бумага, металл, батарейки,
  одежда, электроника, опасные) + чипс «🟢 Открыто» и сброс одним нажатием
- **Счётчик результатов** «Найдено: X из Y»
- **Карточка пункта**: адрес, график работы, текущий статус, принимаемые типы
- **Построение маршрута** до пункта (OSRM + GPS-слежение)
- **Избранное** с локальным сохранением (SharedPreferences)
- **Онбординг**, гид по раздельному сбору, профиль
- Нижняя навигация: Карта / Избранное / Гид / Профиль
- Адаптивный UI под мобильные экраны

## 🛠 Технологии и зафиксированные версии
| Компонент | Версия |
|---|---|
| Flutter / Dart | 3.27.0 / 3.6.0 |
| yandex_mapkit | 4.1.0 (без `^`) |
| Yandex MapKit (native) | `com.yandex.android:maps.mobile:4.6.1-lite` |
| Gradle / AGP / Kotlin | 8.9 / 8.7.0 / 2.1.0 |
| Android NDK | 27.0.12077973 |
| База данных | Supabase (PostgreSQL) |
| Маршрутизация | OSRM API |
| Прочее | geolocator, shared_preferences, url_launcher, google_fonts |

> ⚠️ Версии намеренно зафиксированы. Не выполняйте `flutter upgrade` /
> `flutter pub upgrade` — это ломает совместимость MapKit и Gradle.

## ⚙️ Как запустить
1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/YasminParlak/ecopoint
   ```
2. Скопируйте `lib/core/constants/env.example.dart` → `lib/core/constants/env.dart`
   и заполните ключи Supabase.
3. Добавьте ключ MapKit в `android/local.properties`:
   ```properties
   yandexApiKey=ВАШ_КЛЮЧ_MapKit_Mobile_SDK
   ```
   Ключ также прописывается в `android/app/src/main/kotlin/.../MainApplication.kt`
   через `MapKitFactory.setApiKey(...)`.
4. Убедитесь, что установлен **Android NDK 27.0.12077973**
   (задаётся в `android/app/build.gradle.kts`).
5. Запустите:
   ```bash
   flutter pub get
   flutter run
   ```

### 💡 Windows с кириллицей в имени пользователя
Если профиль Windows содержит кириллицу (например `C:\Users\Татьяна`),
вынесите кэш Gradle в путь без кириллицы, иначе сборка падает:
```powershell
setx GRADLE_USER_HOME "C:\gradle_home"
```

## 🔑 Ключи
- **MapKit Mobile SDK** — получить в кабинете разработчика Яндекса
  (сервис именно «MapKit SDK», не JavaScript API и не Geocoder).
- **Supabase** — URL и publishable-key проекта с таблицей `collection_points`.