Pod::Spec.new do |s|
  s.name         = 'KVOBlockBinding'
  s.version      = '0.0.1'
  s.summary      = 'Bind blocks to properties using KVO.'
  s.author       = { 'Ray Yamamoto Hilton' => 'ray@wirestorm.net' }
  s.homepage     = 'https://github.com/rayh'
  s.platform     = :ios, '5.0'
  s.source       = { :git => 'https://github.com/alextud/kvo-block-binding.git' }
  s.source_files = 'KVOBlockBinding/*.{h,m}'
  s.requires_arc = true
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
end