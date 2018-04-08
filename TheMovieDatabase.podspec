Pod::Spec.new do |s|
  s.name = 'TheMovieDatabase'
  s.version = '0.8.3'
  s.license = 'Apache 2'
  s.summary = 'Swift interface for The Movie Database'
  s.homepage = 'https://github.com/coodly/TheMovieDatabase'
  s.authors = { 'Jaanus Siim' => 'jaanus@coodly.com' }
  s.source = { :git => 'git@github.com:coodly/TheMovieDatabase.git', :tag => s.version }

  s.tvos.deployment_target = '9.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/TheMovieDatabase/*.swift'

  s.requires_arc = true
end
