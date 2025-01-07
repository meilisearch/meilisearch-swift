#
# Be sure to run `pod lib lint MeiliSearch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

# Loads version from `PackageVersion.current` defined in the PackageVersion.swift file.
package_version = begin
  File
    .read("./Sources/MeiliSearch/Model/PackageVersion.swift")
    .match(/"([0-9]+.[0-9]+.[0-9]+)"/i)[1]
rescue
  raise "Cannot retrieve a valid semver.org version in the PackageVersion.swift file"
end

Pod::Spec.new do |s|
  s.name             = 'MeiliSearch'
  s.version          = package_version
  s.summary          = 'The Meilisearch API client written in Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  meilisearch-Swift is a client for Meilisearch written in Swift.

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
  s.author           = { 'Meilisearch' => 'bonjour@meilisearch.com' }
  s.source           = { :git => 'https://github.com/meilisearch/meilisearch-swift.git', :tag => package_version }
  s.social_media_url = 'https://twitter.com/meilisearch'

  s.source_files = 'Sources/**/*.{h,m,swift}'

  s.swift_versions = ['5.2']
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'

end
