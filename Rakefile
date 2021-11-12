# frozen_string_literal: true

require "bundler/gem_tasks"
task default: %i[]

namespace :go do
  task :build do
    sh "go build -o ./lib/no_tbj/main.exe ./go/main.go"
  end

  task :modify do
    File.open("./lib/no_tbj/main.exe", "r+") do |f|
      f.seek(16 * 4 + 14)
      f.write("!!notbj!!")
    end
  end
end

task go: %i[go:build go:modify]
