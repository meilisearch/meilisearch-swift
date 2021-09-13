#
# Be sure to run `pod lib lint MeiliSearch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MeiliSearch'
  s.version          = '0.8.2'
  s.summary          = 'The MeiliSearch API client written in Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  MeiliSearch-Swift is a client for MeiliSearch written in Swift.

  ## Features:

    * Complete full API wrapper
    * Easy to install, deploy, and maintain
    * Highly customizable
    * No external dependencies
    * Thread safe
    * Uses Codable
                       DESC

  s.homepage         = 'https://github.com/meilisearch/meilisearch-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MeiliSearch' => 'bonjour@meilisearch.com' }
  s.source           = { :git => 'https://github.com/meilisearch/meilisearch-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/meilisearch'

  s.source_files = 'Sources/**/*'
  s.swift_versions = ['5.2']
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'

end
