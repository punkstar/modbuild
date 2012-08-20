# -*- encoding: utf-8 -*-
require File.expand_path('../lib/modbuild', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nick Jones"]
  gem.email         = ["nick@nicksays.co.uk"]
  gem.description   = %q{This script gives you a running start by generating an XML file that you can then load in the admin interface containing most of the information you'll need, such as all of the files included in the extension and any metadata that you've included in your modman file.}
  gem.summary       = %q{Build a skeleton Magento Connect extension package file from your modman contents}
  gem.homepage      = "https://github.com/punkstar/modbuild"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "modbuild"
  gem.require_paths = ["lib"]
  gem.version       = Modbuild::VERSION
end
