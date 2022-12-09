#
# Be sure to run `pod lib lint Sona.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Sona'
  s.version          = '0.1.0'
  s.summary          = 'Sona 平台是一个搭建语音房产品的全端解决方案，包含了房间管理、实时音视频、房间IM、长连接网关等能力'

  s.homepage         = 'https://github.com/BixinTech/sona-ios'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Ju Liaoyuan' => 'juliaoyuan@bixin.cn' }
  s.source           = { :git => 'https://github.com/BixinTech/sona-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sona/Classes/**/*'
  s.resource     = "Sona/Resources/*.bundle"
  
  s.dependency 'ZegoLiveRoom'
  s.dependency 'Mercury-iOS'
  s.dependency 'TXLiteAVSDK_Professional'

  s.dependency 'MJExtension'
  s.dependency 'ReactiveObjC'
end
