#
# Be sure to run `pod lib lint SQRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SQRouter'
  s.version          = '0.1.0'
  s.summary          = 'SQRouter.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  基于runtime映射的原理实现的免注册路由
                       DESC

  s.homepage         = 'https://github.com/mj230816/SQRouter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mj230816' => 'songqian1@xiaomi.com' }
  s.source           = { :git => 'https://github.com/mj230816/SQRouter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_versions = '5.0'
  s.source_files = 'SQRouter/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SQRouter' => ['SQRouter/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.subspec 'Contacts' do |contacts|
      contacts.source_files = 'SQRouter/Classes/Contacts/**/*'
  end
  
end
