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

### Интеграция фреймворка 

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

