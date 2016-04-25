Pod::Spec.new do |s|
  s.name = 'TheMovieDatabase'
  s.version = '0.1.0'
  s.license = 'Apache 2'
  s.summary = 'Swift interface for The Movie Database'
  s.homepage = 'https://github.com/coodly/TheMovieDatabase'
  s.authors = { 'Jaanus Siim' => 'jaanus@coodly.com' }
  s.source = { :git => 'git@github.com:coodly/TheMovieDatabase.git', :tag => s.version }

  s.tvos.deployment_target = '9.0'

  s.source_files = 'Source/*.swift'

  s.requires_arc = true
end
