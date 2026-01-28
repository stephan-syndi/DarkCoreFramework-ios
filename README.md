# Интеграция DarkCoreFramework

## Подготовка к интеграции 

> Перед началом стоит установить необходимые pod-ы в проект:
- Firebase
- Appsflyer
- Alomafire 

1. Закройте проект, если он открыт и откройте терминал и перейдите в католог вашего приложения:

``` bash 
    cd yourpath // можно из финдера перетянуть каталог с вашим проектом 
```
2. Убедившись что вы находитесь в директории вашего проекта, вызовите команду для установки cocoapod:

``` bash 
     
```

3. Открыть *Podfile* и заменить его следующим кодом:
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



