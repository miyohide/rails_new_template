require "fileutils"

# pathで指定されたファイルに対してblockの処理を実行して
# 戻り値が偽のものを集めてファイルに書き込む。
# 条件にマッチしなかったものだけを集める=不要なものを削除する
# という使い方をする。
def filter_lines(path, &block)
  files = Dir.glob(path).select { |f| File.file?(f) }
  files.each do |f|
    content = File.read(f)
    filtered = content.lines.reject do |l|
      block.call(l)
    end.join
    File.write(f, filtered)
  end
end

# コメント行を削除する
def remove_comments(path)
  filter_lines(path) do |l|
    l.strip.start_with?("#")
  end
end

# GemをGemfileから取り除く
def remove_gem(name)
  filter_lines("Gemfile") do |l|
    l.include?(name)
  end
end

# 空白行を削除する
def remove_empty_lines(path)
  # パラグラフモードで読み込む
  content = IO.readlines(path, "").join
  File.write(path, content)
end

remove_comments("Gemfile")
%w(coffee-rails jbuilder web-console turbolinks).each do |gem|
  remove_gem(gem)
end

gem "lograge"

gem_group :development do
  gem "brakeman"
  gem "bullet"
  gem "license_finder"
  gem "bundler-audit"
end

gem_group :development, :test do
  gem "pry-rails"
  gem "rubocop", require: false
  gem "rspec-rails"
end

gem_group :test do
  gem 'simplecov', require: false
end

run "bundle install"
generate("rspec:install")

initializer 'lograge.rb', <<-CODE
  Rails.application.configure do
    config.lograge.enabled = true
  end
CODE

remove_empty_lines("Gemfile")
