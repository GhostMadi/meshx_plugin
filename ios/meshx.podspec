
Pod::Spec.new do |s|
  s.name             = 'meshx'
  s.version          = '0.1.0'
  s.summary          = 'Open-source Flutter plugin for offline Bluetooth mesh-like messaging.'
  s.description      = <<-DESC
meshx — Flutter plugin prototype that provides a Bridgefy-style API for offline messaging.
This podspec is for the iOS part of the plugin (Swift).
  DESC
  s.homepage         = 'https://github.com/GhostMadi/meshx_plugin.git'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'meshx' => 'opensource@example.com' }
  s.source           = { :path => '.' }

  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'

  # Flutter pods are static by default; keep this for safety with Swift linking.
  s.static_framework = true

  # Ensure the flutter framework is available at build time
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
