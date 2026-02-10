# Интеграция DarkCoreFramework

- [Подготовка](#подготовка)
    + [APNs](#notification-service-extension)
- [Интеграция фреймворка](#интеграция-фреймворка)
- [Настройка кора](#настройка-кора)
    + [Настройка конфигурации](#настройка-конфигурации)
    + [Регистрация View + Фантик](#регистрация-view--фантик)
    + [PemissionView](#permissionview)    
- [FAQ](#faq)

> [!WARNING]
> Настоятельно рекомендуется обратить внимание на работу с экраном кастомного принятия разрешения на отправку уведомлений!

> [!NOTE]
> Ресурсы для `View` берутся из `Assets` и ограничений на нейминги нет. 

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
```podfile
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
> [!IMPORTANT] 
> Замените _YourTargetName_ на Ваше имя приложения. 

4. Откройте проект через файл с расширением _.xcworksoace_. Выберите свой Target в **Project Navigator**: Вкладка **General** -> Найдите секцию **Frameworks, Libraries, and Embedded Content** и удалите добавленные фреймворки (FirebaseCore, FirebaseMessaging, AppsFlyerLib) если такие добавились. 

5. В секции **Supported Destinations** оставьте только *iPhone*
6. Вкладка **Signing & Capabilities**, снимите галочку с *Automatically manage signing*. Добавьте **Capability**:
- Background Modes: Background fetch + Remote notifications
- Push Notifications 
- Camera: Allow to this app use your camera.
- Microphone: Allows microphone access.
- Photo Library: Allows photo library access.
- User Tracking: Your data will be used to personalize ads.

7. Добавьте в проект **Notification Service Extension** и настройте его.
---
#### Notification Service Extension 

В проект добавить **GoogleService-Info.plist** скаченный на сайте Firebase вашего проекта, после чего добавить APNs.

После добавления **APNs** необходимо отредактировать скрипт `NotificationService` для получения уведомлений с отображением изображений. Вы можете просто скопировать код из [примера](https://github.com/stephan-syndi/DarkCoreFramework-ios/blob/main/NotificationService%20Sample/NotificationService.swift) или исправить свой скрипт. 

> [!NOTE]
> Target `notifications` должен иметь следующие фреймворки и библиотеки и помечены как `Do Not Embed`:
> + `FirebaseCore.framework`
> + `FirebaseMessaging.framework`


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
> [!NOTE]
> Если билд собрался и запустился на симуляторе без ошибок, переходим к настройке кора. 

## Настройка кора 

> [!NOTE]
> Фреймворк не предлагает реализаций View для Splash (Curtain), Internetn, Permission. Вместо этого Вам необходимо самостоятельно реализовать данные окна. 

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
----
#### Настройка конфигурации

Для того, чтобы ваш проект был способен взаимодействовать с кором, вам необходимо зарегистрировать **ApplicationDelegate**, который представлен классом **DarkAppDelegate**: `@UIApplicationDelegateAdaptor(DarkAppDelegate.self) var appDelegate`.
После чего вам необходимо создать переменную `Configuration` которая хранит настройки коро: 
```swift
 let config = Configuration(
        appsDevKey: "yourAFKey",                    // код приложения в AppsFlyer
        appleAppId: "yourAppleID",                  // id приложения из Apple Store
        endpoint: "https://yourDomain",             // ваша доменная ссылка без '/'
        firebaseGCMSenderId: "yourGCMSenderId"      // код проекта в Firebase
    )
```
> [!WARNING]
> Соблюдайте порядок инциализации параметров в структуре `Configuration` как в примере.

----
#### Регистрация View + Фантик

Чтобы фреймворк правильно обрабатывал вашу реализацию `View` и `фантика` необходимо их зарегистрировать в `AppRouter`. Для этого создай параметр `private let router: AppRouter` и в `init()` проинициализируйте и передайте в делегат следующим образом:
```swift
    init(){
        router = DarkCore.configure(config: config, clearView: ContentView()) 
        // ... 

        appDelegate.router = router
    }
```
`router = DarkCore.configure(config: config, clearView: ContentView())` - метод `configure` принимает `2 параметра`:
- **config** ранее созданная переменная типа `Configuration`;
- **ConentView** рутовый `View` вашего `фантика`. 

Для работы остальных `View` необходимо реализовать или взять из репозитория [шаблоны](https://github.com/stephan-syndi/DarkCoreFramework-ios/tree/main/View%20Samples) и зарегистрировать их в `AppRouter` через метод `setScreen<V: View>(screen: AppScreen, view: V)`, где `screen` - маркер для регистрируемого окна, `view` - целевое окно. 

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

`AppRouter` необходимо передать как `EvironmentObject`, для этого в **body** сделайте следующее: 

```swift 
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(router)
        }
    }
```
----
### PermissionView

Отдельно от всех `View` свои особенности работы и реализации имеет экран разрешений - `PermissionView`. 

Для обработки логики кнопок, данный экран требует зависимость от `PermissionProtocol`, который помогает связать Ваш `View` с кором. 
В вашем кастомно `View` вам необходимо создать переменную типа `PermissionProtocol` и потребовать в `init()` получение зависимости:

```swift 
import SwiftUI
import DarkCoreFramework

struct PermissionView: View {
    var viewModel: PermissionProtocol
    
    init(viewModel: PermissionProtocol) {
        self.viewModel = viewModel
    }

    // your code
}
```

После чего в можете смело подписать ваши кнопки (`Apply, Skip`) на методы обработки из протокола:
-  `onRequestNotificationPermission()` - запрос на принятие разрешений 
- `onSkip()` - пропуск разрешения на 3 дня. 

При регистрации окна запросов необходимо будет прокинуть зависимость из вашего `AppRouter` через метод `getPermissionViewModel()`:
```swift
@main
struct YourApp: App {
    // your code

    init(){
        // your code

        router.setScreen(screen: .permission, view: PermissionView(viewModel: router.getPermissionViewModel()))
     
        // your code
    }

    // your code

}
```

> [!NOTE] 
> Полный пример можно посмотреть [здесь](https://github.com/stephan-syndi/DarkCoreFramework-ios/blob/main/View%20Samples/PermissionView.swift)


Полный пример кода `YourApp` 

```swift
import SwiftUI
import DarkCoreFramework

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(DarkAppDelegate.self) var appDelegate
    let config = Configuration(
        appsDevKey: "yourAFKey",
        appleAppId: "yourAppleID",
        endpoint: "https://yourDomain", 
        firebaseGCMSenderId: "yourGCMSenderId"
    )

    private let router: AppRouter
    
    init(){
        router = DarkCore.configure(config: config, clearView: ContentView())
        
        router.setScreen(screen: .curtain, view: CurtainView())
        router.setScreen(screen: .permission, view: PermissionView(viewModel: router.getPermissionViewModel()))
        router.setScreen(screen: .internet, view: InternetAlertView())
        
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

## FAQ 
#### Sandbox: rsync.samba 
Проблема распространненая, решение можно посмотреть [здесь](https://stackoverflow.com/questions/76590131/error-while-build-ios-app-in-xcode-sandbox-rsync-samba-13105-deny1-file-w)
