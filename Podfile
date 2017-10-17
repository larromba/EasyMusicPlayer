# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'EasyMusic' do

    pod 'Firebase/Analytics'
    pod 'Fabric'
    pod 'Crashlytics'
    
    target 'EasyMusicTests' do
        inherit! :search_paths
        
        pod 'Firebase/Analytics'
    end

    target 'EasyMusicUITests' do
        inherit! :search_paths
        
        pod 'Firebase/Analytics'
    end
end

# work-around to handle XCode 8 swift versioning
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
