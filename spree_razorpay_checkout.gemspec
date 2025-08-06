lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'spree_razorpay_checkout/version'

Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY
  spec.name     = 'spree_razorpay_checkout'
  spec.version  = SpreeRazorpayCheckout.version
  spec.summary  = 'Razorpay integration for Spree Commerce 5.x'
  spec.description = 'Seamless Razorpay checkout integration for Spree Commerce 5.x stores'

  spec.required_ruby_version = '>= 3.1.2'

  spec.authors  = ['Umesh Ravani']
  spec.email    = ['umeshravani98@gmail.com']
  spec.homepage = 'https://github.com/umeshravani/spree_razorpay'
  spec.license  = 'BSD-3-Clause'

  spec.files = Dir['lib/**/*', 'README.md', 'LICENSE.txt']
  #spec.files = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(%r{^spec/fixtures}) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'razorpay'
  spec.add_dependency 'spree', '>= 5.0.0'
  spec.add_dependency 'spree_backend'
  spec.add_dependency 'spree_extension'
  spec.add_dependency 'spree_frontend'

  spec.add_development_dependency 'spree_dev_tools'

  # Metadata for RubyGems.org
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
end
