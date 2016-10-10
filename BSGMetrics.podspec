#
# Be sure to run `pod lib lint BSGMetrics.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BSGMetrics'
  s.version          = '0.1.5'
  s.summary          = 'Send simple JSON for metrics collection.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A client implementation for Bootstragram's BSGMetrics analytics product.
                       DESC

  s.homepage         = 'https://github.com/Bootstragram/BSGMetrics'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bootstragram' => 'contact@bootstragram.com' }
  s.source           = { :git => 'https://github.com/Bootstragram/BSGMetrics.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bootstragram'

  s.ios.deployment_target = '8.0'

  s.source_files = 'BSGMetrics/Classes/**/*'

  # s.resource_bundles = {
  #   'BSGMetrics' => ['BSGMetrics/Assets/*.png']
  # }

  s.public_header_files = [
    'BSGMetrics/Classes/BSGMetrics.h',
    'BSGMetrics/Classes/BSGMetricsConfiguration.h',
    'BSGMetrics/Classes/BSGMetricsEvent.h'
  ]
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking'
  s.dependency 'FCModel'
end
