# Интеграция DarkCoreFramework

- [Подготовка](#подготовка)
- [Интеграция фреймворка](#интеграция-фреймворка)

## Подготовка

Перед началом стоит установить необходимые pod-ы в проект:
- Firebase
- Appsflyer
- Alomafire 

1. Закройте проект, если он открыт и откройте терминал и перейдите в католог вашего приложения:

``` bash 
cd yourpath // можно из финдера перетянуть каталог с вашим проектом 
```
2. Убедившись что вы находитесь в директории вашего проекта, вызовите команду для установки cocoapod:

``` bash 
pod init
```
В проекте создастся _.xcworkspace_ и _podfile_. 

3. Откройте **Podfile** и заменить его содержимое следующим кодом:
``` podfile
platform :ios, '15.0'

target 'YourTargetName' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for YourTarget
  pod 'Alamofire', '= 5.8'
  pod 'AppsFlyerFramework', '= 6.12'
  pod 'Firebase/Core', '12.7.0'
  pod 'Firebase/Messaging', '12.7.0'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end

target 'notifications' do
  use_frameworks!
  
  pod 'Alamofire', '= 5.8'
  pod 'AppsFlyerFramework', '= 6.12'
  pod 'Firebase/Core', '12.7.0'
  pod 'Firebase/Messaging', '12.7.0'
  
end

```
> ⚠️ Note: Замените _YourTargetName_ на Ваше имя приложения. 

4. Откройте проект через файл с расширением _.xcworksoace_. Выберите свой Target в **Project Navigator**: Вкладка **General** -> Найдите секцию **Frameworks, Libraries, and Embedded Content** и удалите добавленные фреймворки (FirebaseCore, FirebaseMessaging, AppsFlyerLib) если такие добавились. 

5. В секции **Supported Destinations** оставьте только *iPhone*
6. Вкладка **Signing & Capabilities**, снимите галочку с *Automatically manage signing*. Добавьте **Capability**:
- Background Modes: Background fetch + Remote notifications
- Push Notifications 
- Camera: Allow to this app use your camera.
- Microphone: Allows microphone access.
- Photo Library: Allows photo library access.
- User Tracking: Your data will be used to personalize ads.

7. Добавьте в проект **Notification Service Extension** и настройте его как обычно. 

## Интеграция фреймворка 

#### 1. Добавьте новый XCFramework:

1. Откройте Finder и перейдите в директории где распакован фреймворк
2. Перетащите `DarkCoreFramework.xcframework` в Xcode Project Navigator
3. В диалоге выберите:
   - ✅ **Copy items if needed**
   - ✅ Target: **YourTarget**
   - Нажмите **Finish**

#### 2. Настройте Embed & Sign:

1. Выберите проект в Project Navigator (самый верхний элемент)
2. Выберите Target **YourTarget**
3. Вкладка **General**
4. Найдите секцию **Frameworks, Libraries, and Embedded Content**
5. Найдите `DarkCoreFramework.xcframework`
6. В колонке справа выберите **"Embed & Sign"** (не "Do Not Embed")


#### 3. Очистите и пересоберите:

1. В Xcode: **Product** → **Clean Build Folder** (⇧⌘K)
2. В Xcode: **Product** → **Build** (⌘B)
3. Запустите на симуляторе: **Product** → **Run** (⌘R)
> Если билд собрался и запустился на симуляторе без ошибок, переходим к настройке кора. 

## Настройка кора 

> ⚠️ Note: Фркймворк не предлагает реализаций View для Splash (Curtain), Internetn, Permission. Вместо этого Вам необходимо самостоятельно реализовать данные окна. 

1. Откройте проект и в корне создайте **view**: `MainContentView`. 
2. Добавьте импорт на библиотеку `import DarkCoreFramework`. 
3. Замените содержимое следующим кодом: 

```swift
import SwiftUI
import DarkCoreFramework

struct MainContentView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        router.changeScreen()
    }
} 
```

### Настройка конфигурации

Для того, чтобы ваш проект был способен взаимодействовать с кором, вам необходимо зарегистрировать **ApplicationDelegate**, который представлен классом **DarkAppDelegate**: `@UIApplicationDelegateAdaptor(DarkAppDelegate.self) var appDelegate`.
После чего вам необходимо создать переменную `Configuration` которая хранит настройки коро: 
```swift
 let config = Configuration(
        appsDevKey: "yourAFKey",
        appleAppId: "yourAppleID",
        endpoint: "https://yourDomain", // без '/'
        firebaseGCMSenderId: "yourGCMSenderId"
    )
```
> ⚠️ Note: Соблюдайте порядок инциализации параметров в структуре `Configuration` как в примере.

### Регистрация View + Фантик

Чтобы фреймворк правильно обрабатывал вашу реализацию `View` и `фантика` необходимо их зарегистрировать в `AppRouter`. Для этого создай параметр `private let router: AppRouter` и в `init()` сделайте следующее:
```swift
    init(){
        router = DarkCore.configure(config: config, clearView: ContentView()) 

    }
```
`router = DarkCore.configure(config: config, clearView: ContentView())` - метод `configure` принимает `2 параметра`:
- **config** ранее созданная переменная типа `Configuration`;
- **ConentView** рутовый `View` вашего `фантика`. 

Для работы остальных `View` необходимо реализовать или взять из репозитория шаблоны и зарегистрировать их в `AppRouter` через метод `setScreen<V: View>(screen: AppScreen, view: V)`, где `screen` - маркер для регистрируемого окна, `view` - целевое окно. 

`AppScreen` содержит следующие маркеры: 
    + __curtain__ - `SplashView` или `CurtainView`, ваш загрузочный экрна 
    + __permission__ - `PermissionView` окно запроса разрешения для уведомлений
    + __internet__ - `InternetView` окно с предупреждением об отсутствии интернета
    + __browser__ - маркер для работы `WebView`, **в настройке кора не участвует**
    + __clear__ - маркер для вашего `фантика`, зачастую не нужен для настройки, так как фантик регистрируется при инициализации `AppRouter`

Пример регистрации

```swift
init() {
    // your code 

    router.setScreen(screen: .curtain, view: SplashView())
}
```


Откройте `YourApp` файл и добавьте следующий код:
```swift 
import DarkCoreFramework
// ...

struct YourApp: App {
    @UIApplicationDelegateAdaptor(DarkAppDelegate.self) var appDelegate
    let config = Configuration(
        appsDevKey: "yourAFKey",
        appleAppId: "yourAppleID",
        endpoint: "https://yourDomain", // без '/'
        firebaseGCMSenderId: "yourGCMSenderId"
    )

    private let router: AppRouter
    
    // ...

    init(){
        print("👉 init MyApp") 

        router = DarkCore.configure(config: config, clearView: ContentView())

        // установить кастомные View для Internet, Splash, Permission
        router.setScreen(screen: .curtain, view: CurtainView())

        appDelegate.router = router
    }

    var body: some Scene {
        WindowGroup {
             MainContentView()
                .environmentObject(router)
        }
    }
}
```