Pod::Spec.new do |s|
  s.name = 'CommonKeyboard'
  s.version = '1.0.8'
  s.license = { :type => "MIT", :file => "LICENSE.md" }

  s.summary = 'An elegant Keyboard library for iOS.'
  s.homepage = 'https://github.com/kaweerutk/CommonKeyboard'
  s.author = { "Kaweerut Kanthawong" => "iamkevinjoon@gmail.com" }
  s.source = { :git => 'https://github.com/kaweerutk/CommonKeyboard.git', :tag => s.version }
  s.source_files = 'Sources/*.swift'

  s.pod_target_xcconfig = {
     "SWIFT_VERSION" => "5",
  }

  s.swift_version = '5'

  s.ios.deployment_target = '12.0'

  s.requires_arc = true

end
