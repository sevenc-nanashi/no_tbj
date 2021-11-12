# frozen_string_literal: true

require "bundler/gem_tasks"
task default: %i[]

namespace :go do
  task :build do
    File.delete("./lib/no_tbj/main.exe") if File.exist?("./lib/no_tbj/main.exe")
    sh "go build -o ./lib/no_tbj/main.exe ./go/main.go"
  end

  task :modify do
    require_relative "lib/no_tbj"
    File.open("./lib/no_tbj/main.exe", "ab") do |f|
      f.write(NoTBJ::CHECKS)
    end
  end
end

task go: %i[go:build go:modify]
