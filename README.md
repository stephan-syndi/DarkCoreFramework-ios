# Интеграция DarkCoreFramework

## Подготовка к интеграции 

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

1. Откройте проект и в корне создайте **view**: `MainContentView`. 
2. Добавьте иморт на библиотеку `import DarkCoreFramework`. 
3. Замените содержимое следующим кодом: 

```swift 
struct MainContentView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        router.changeScreen()
    }
} 
```
4. Откройте `YourApp` файл и добавьте следующий код:
```swift 
import DarkCoreFramework
// ...

struct YourApp: App {
    @UIApplicationDelegateAdaptor(DarkAppDelegate.self) var appDelegate
    let config = Configuration(
        appsDevKey: "yourAFKey",
        appleAppId: "yourAppleID"
    )

    private let router: AppRouter
    
    // ...

    init(){
        print("👉 init MyApp") 

        router = DarkCore.configure(config: config, clearView: ContentView())
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

## Кастомизация ресурсов

### Изображения

```swift
let config = Configuration(
    appsDevKey: "your_key",
    appleAppId: "your_id",
    
    // Свои изображения
        customMainBack: "my_background",           // Фоновое изображение
        customLogo: "my_logo",                     // Логотип приложения
        customCurtainHeader: "my_header",          // Заголовок на экране загрузки
        customPopup: "my_popup_bg",                // Фон popup окна
        customPermissionBtnImage: "my_btn_image"   // Изображение кнопки разрешений
    )
```

### Цвета

```swift
let config = Configuration(
    appsDevKey: "your_key",
    appleAppId: "your_id",
    
    // Свои цвета (имена из Assets.xcassets)
    customBackColor: "MyBackgroundColor",
    customPermissionBtnColor: "MyButtonColor",
    customPermissionFontColor: "MyTextColor",
    customPermissionFadeColor: "MyGradientColor"
)
```

### Тексты

```swift
let config = Configuration(
    appsDevKey: "your_key",
    appleAppId: "your_id",
    
    // Свои тексты
    customTitlePermission: "Разрешите уведомления",
    customSubtitlePermission: "Будьте в курсе всех бонусов",
    customInternetMessage: "Проверьте интернет-соединение"
)
```

## Полный пример

```swift
import DarkCoreFramework
import SwiftUI

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(DarkAppDelegate.self) var appDelegate
    
    init() {
        let config = Configuration(
            appsDevKey: "your_appsflyer_key",
            appleAppId: "your_apple_id",
            backIsImage: true,
            permissionBtnIsImage: false,
            splitScreen: false,
            
            // Кастомные ресурсы
            customMainBack: "my_custom_background",
            customLogo: "my_app_logo",
            customCurtainHeader: "my_loading_header",
            customPopup: "my_popup_background",
            customPermissionBtnImage: "my_button_image",
            
            customBackColor: "AppBackgroundColor",
            customPermissionBtnColor: "PrimaryButtonColor",
            customPermissionFontColor: "PrimaryTextColor",
            customPermissionFadeColor: "GradientColor",
            
            customTitlePermission: "Get Notifications",
            customSubtitlePermission: "Stay updated with bonuses",
            customInternetMessage: "No internet connection"
        )
        
        let router = DarkCore.configure(config: config, clearView: ContentView())
        appDelegate.router = router
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Как добавить свои ресурсы

1. **Изображения**: Добавьте в `Assets.xcassets` вашего проекта
2. **Цвета**: Создайте Color Set в `Assets.xcassets`
3. **Укажите имена**: Передайте имена ресурсов в `Configuration`

## Приоритет загрузки

Фреймворк ищет ресурсы в следующем порядке:

1. **Кастомный ресурс из вашего приложения** (если указан)
2. **Стандартный ресурс из вашего приложения** (если есть)
3. **Стандартный ресурс из фреймворка**
4. **Программный fallback** (автоматически сгенерированное изображение)

## Примечания

- Если параметр `customXXX` не указан, используются стандартные ресурсы фреймворка
- Все параметры опциональны - можно переопределить только нужные
- Ресурсы загружаются из `Bundle.main` вашего приложения