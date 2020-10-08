#
# Be sure to run `pod lib lint MeiliSearch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MeiliSearch'
  s.version          = '0.4.0'
  s.summary          = 'MeiliSearch-Swift is a client for MeiliSearch written in Swift.'
  s.description      = <<-DESC
MeiliSearch-Swift is a client for MeiliSearch written in Swift. MeiliSearch is a powerful, fast, open-source, easy to use and deploy search engine. Both searching and indexing are highly customizable. Features such as typo-tolerance, filters, and synonyms are provided out-of-the-box.
                       DESC

  s.homepage         = 'https://github.com/meilisearch/meilisearch-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ppamorim' => 'pp.amorim@hotmail.com' }
  s.source           = { :git => 'https://github.com/meilisearch/meilisearch-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.3'

  s.source_files = 'Sources/MeiliSearch/*', 'Sources/MeiliSearch/Model/*'
  s.swift_versions = '5.0'
end
