Pod::Spec.new do |s|
  s.name             = 'GestureInstructions'
  s.version          = '0.0.1'
  s.summary          = 'Framework for showing gesture hints'

  s.description      = <<-DESC
Framework to show gesture animations on top of the viewController.
                       DESC

  s.homepage         = 'https://github.com/rinat-enikeev/GestureInstructions'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rinat-enikeev' => 'rinat.enikeev@gmail.com' }
  s.source           = { :git => 'https://github.com/rinat-enikeev/GestureInstructions.git', :tag => s.version.to_s }
  
  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'
  s.source_files = 'GestureInstructions/Classes/**/*'
end
