platform :ios, '13.0'
inhibit_all_warnings!

install! 'cocoapods', :deterministic_uuids => false

target 'NLSpotify' do
    use_frameworks!
    pod 'AFNetworking'
    pod 'YYModel'
    pod 'Masonry'
    # pod 'FMDB' (已经光荣下岗)
    pod 'SocketRocket'
    pod 'JXCategoryView'
    pod 'SDWebImage'
    pod 'WCDB.objc'
    pod 'HysteriaPlayer'
    pod 'IQKeyboardManager'
    pod 'ReactiveObjC'
    pod 'LookinServer', :configurations => ['Debug']
end

# 👇 把这段魔法脚本直接复制粘贴到 Podfile 的最下面 👇
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 强行把所有 Pods 的最低部署版本拉高到 iOS 13.0，彻底干掉 libarclite 报错！
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end