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

remove_comments("Gemfile")
%w(coffee-rails jbuilder web-console turbolinks).each do |gem|
  remove_gem(gem)
end
