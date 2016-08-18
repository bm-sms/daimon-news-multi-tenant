source "https://rubygems.org"

ruby "2.3.1"

gem "rails", "~> 4.2.7.1"

gem "active_decorator"
gem "active_link_to"
gem "active_model_serializers"
gem "ancestry"
gem "bootstrap-sass"
gem "bootstrap_form"
gem "bourbon"
gem "browser"
gem "carrierwave"
gem "cocoon", github: "mtsmfm/cocoon", branch: "fix-on-ready-for-jquery-3" # cocoon doesn't work well with jQuery 3 (https://github.com/nathanvda/cocoon/pull/379)
gem "daimon-markdown"
gem "daimon_news-layout", github: "bm-sms/daimon_news-layout"
gem "devise", ">= 3.5.4"
gem "fog"
gem "font-awesome-sass"
gem "gretel", github: "lassebunk/gretel" # To use https://github.com/lassebunk/gretel/commit/b1dd8659 (it is unreleased until 3.0.8)
gem "haml-rails"
gem "kaminari"
gem "meta-tags", require: "meta_tags"
gem "order_as_specified"
gem "pg"
gem "puma"
gem "rails-i18n"
gem "rambulance"
gem "redcarpet"
gem "rouge"
gem "rroonga"
gem "sass-rails"
gem "seedbank"
gem "select2-rails"
gem "sitemap_generator"
gem "sprockets-es6"
gem "uglifier"

source "https://rails-assets.org" do
  gem "rails-assets-bootstrap-markdown-editor"
  gem "rails-assets-jquery"
  gem "rails-assets-jquery-ujs"
  gem "rails-assets-marked"
  gem "rails-assets-spectrum"
end

group :development, :test do
  gem "factory_girl"
  gem "pry-byebug"
end

group :development do
  gem "launchy"
  gem "pry-rails"
  gem "rails-erd", require: false
  gem "rubocop", require: false
  gem "web-console", "~> 2.0"
end

group :test do
  gem "capybara", github: "tricknotes/capybara", branch: "escape-text-for-have-text" # To avoid Capybara's bug. see for detail: https://github.com/jnicklas/capybara/pull/1739
  gem "database_cleaner"
  gem "poltergeist"
  gem "test-unit-rails", require: false
end

group :production do
  gem "airbrake"
  gem "newrelic_rpm"
  gem "rack-contrib", require: "rack/contrib"
  gem "rack-cors"
  gem "rack-timeout"
  gem "rails_12factor"
end
