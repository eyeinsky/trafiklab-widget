Gem::Specification.new do |s|
   s.name        = 'trafiklab-widget'
   s.version     = '0.0.1'

   s.summary     = "Simple TrafikLab GTK widget"
   s.description = "A basic TrafikLab GTK window showing next bus(es) from specified stop"
   s.authors     = ["eyeinsky"]
   s.email       = 'eyeinsky9@gmail.com'
   s.licenses    = ['MIT']
   s.homepage    = 'https://github.com/eyeinsky/trafiklab-widget'
   s.files       = ["lib/trafiklab-widget.rb"]

   s.add_runtime_dependency 'gtk3', '~> 2.2'
   s.add_runtime_dependency 'json', '~> 1.8'
end
