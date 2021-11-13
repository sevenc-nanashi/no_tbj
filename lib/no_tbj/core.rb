require "rbconfig"
require "fileutils"
require_relative "color"

module NoTBJ
  using NoTBJ::Color
  CHECKS = "no_tbj"

  class CLI
    def run
      if ARGV.empty?
        puts "No arguments given.".red
        puts "Please specify a command, {no_tbj help} for more information.".minfo
        exit
      end
      case ARGV[0]
      when "install"
        install
      when "uninstall"
        uninstall
      when "help"
        show_help
      when "info"
        show_info
      else
        puts "Unrecognized command.".red
      end
    end

    def install
      bindir = RbConfig::CONFIG["bindir"]
      files = { skipped_exist: [], skipped_nobat: [], skipped_exception: [], installed: [] }
      add_bundler_script unless File.exist?(File.join(bindir, "bundler"))
      force_level = ARGV.count("-f")
      verbose_level = ARGV.count("-v")
      keep = ARGV.count("-k") > 0
      Dir.glob(File.join(bindir, "*")).each do |file|
        next if File.directory?(file)
        next if File.fnmatch?("*.*", file)
        if File.exist?(file + ".exe") && force_level < 1
          next files[:skipped_exist] << file
        end
        unless [
          File.exist?(file + ".bat"), File.exist?(file + ".cmd"),
          File.exist?(file + ".no_tbj.bat"), File.exist?(file + ".no_tbj.cmd"),
        ].any?
          files[:skipped_nobat] << file
          puts "Could not find bat file for #{file}".minfo
          next
        end

        begin
          FileUtils.cp(exepath, file + ".exe")
        rescue => e
          if verbose_level > 0
            puts "Failed to copy {#{exepath}} to {#{file}.exe}.".red
            puts (verbose_level > 1 ? e.full_message : e.message).lines.map { |l| "  " + l }.join
          end
          files[:skipped_exception] << file
        else
          if keep
            files[:installed] << file
            next
          end
          begin
            FileUtils.mv(file + ".bat", file + ".no_tbj.bat") if File.exist?(file + ".bat")
            FileUtils.mv(file + ".cmd", file + ".no_tbj.cmd") if File.exist?(file + ".cmd")
          rescue => e
            if verbose_level > 0
              puts "Failed to rename {#{file}}.".red
              puts (verbose_level > 1 ? e.full_message : e.message).lines.map { |l| "  " + l }.join
            end
            files[:skipped_exception] << file
          else
            files[:installed] << file
          end
        end
      end
      files = files.map { |k, v| [k, v.map { |f| File.basename(f) }] }.to_h
      puts "Installed for {#{files[:installed].length}} files.".green
      puts "Skipped {#{files[:skipped_exist].length}} files because they already exist, use {-f} to overwrite.".minfo unless files[:skipped_exist].empty?
      puts "Skipped {#{files[:skipped_nobat].length}} files because they don't have a bat or cmd file.".minfo unless files[:skipped_nobat].empty?
      unless files[:skipped_exception].empty?
        puts "Skipped {#{files[:skipped_exception].length}} files because of an exception.".warn
        puts "This usually occurs that the executable is already installed and running.".minfo
      end
    end

    def uninstall
      files = { skipped_notnotbj: [], skipped_exception: [], uninstalled: [] }
      verbose_level = ARGV.count("-v")
      tbj_executables.each do |file|
        begin
          FileUtils.rm(file)
        rescue => e
          if verbose_level > 0
            puts "Failed to remove {#{file}}.".red
            puts (verbose_level > 1 ? e.full_message : e.message).lines.map { |l| "  " + l }.join
          end
          files[:skipped_exception] << file
        else
          begin
            base = file.sub(/\.exe$/, "")
            FileUtils.mv(base + ".no_tbj.bat", base + ".bat") if File.exist?(base + ".no_tbj.bat")
            FileUtils.mv(base + ".no_tbj.cmd", base + ".cmd") if File.exist?(base + ".no_tbj.cmd")
          rescue => e
            if verbose_level > 0
              puts "Failed to rename {#{base}.no_tbj.bat} or {#{base}.no_tbj.cmd}.".red
              puts (verbose_level > 1 ? e.full_message : e.message).lines.map { |l| "  " + l }.join
            end
            files[:skipped_exception] << file
          else
            files[:uninstalled] << file
          end
        end
      end

      files = files.map { |k, v| [k, v.map { |f| File.basename(f) }] }.to_h
      puts "Uninstalled for {#{files[:uninstalled].length}} files.".success
      unless files[:skipped_exception].empty?
        puts "Skipped {#{files[:skipped_exception].length}} files because of an exception.".minfo
        puts "This usually occurs that the executable is running.".minfo
      end
    end

    def show_help
      puts "no_tbj lets you ignore {`Terminate Batch Job (Y/N)`} dialogs.".green
      puts "It installs executable to your Ruby's executable directory."
      puts "{install:}".green
      puts "  no_tbj install".info
      puts "  You can specify {-f} to overwrite existing files.".minfo
      puts "  You can specify {-v} to show verbose output.".minfo
      puts "  You can specify {-k} to keep the original bat/cmd file.".minfo
      puts "{uninstall:}".green
      puts "  no_tbj uninstall".info
      puts "  You can specify {-v} to show verbose output.".minfo
      puts "{info:}".green
      puts "  no_tbj info".info
      puts "  Shows some information.".minfo
    end

    def show_info
      puts "no_tbj version: {#{NoTBJ::VERSION}}".minfo
      puts "Bindir: {#{RbConfig::CONFIG["bindir"]}}".minfo
      puts "Executables: {#{tbj_executables.length}}".minfo
      puts "Executables path: {#{exepath}}".minfo
      puts ""
      puts "GitHub: {https://github.com/sevenc-nanashi/no_tbj}".minfo
      puts "Copyright (c) 2021 {sevenc-nanashi}.".info
    end

    def add_bundler_script
      bundler_ruby = <<~RUBY
        #!/usr/bin/env ruby
        #
        # This file was generated by RubyGems.
        #
        # The application 'bundler' is installed as part of a gem, and
        # this file is here to facilitate running it.
        #

        require 'rubygems'

        version = ">= 0.a"

        str = ARGV.first
        if str
          str = str.b[/\A_(.*)_\z/, 1]
          if str and Gem::Version.correct?(str)
            version = str
            ARGV.shift
          end
        end

        if Gem.respond_to?(:activate_bin_path)
        load Gem.activate_bin_path('bundler', 'bundle', version)
        else
        gem "bundler", version
        load Gem.bin_path("bundler", "bundle", version)
        end
      RUBY
      File.write(File.join(RbConfig::CONFIG["bindir"], "bundler"), bundler_ruby)
      File.write(File.join(RbConfig::CONFIG["bindir"], "bundle"), bundler_ruby)
    end

    private

    def tbj_executables
      bindir = RbConfig::CONFIG["bindir"]
      Dir.glob(File.join(bindir, "*.exe")).filter do |file|
        next if File.directory?(file)
        File.open(file, "rb") do |f|
          f.seek(-CHECKS.length, IO::SEEK_END)
          f.read(CHECKS.length) == CHECKS
        end
      end
    end

    def exepath
      File.join(__dir__, "runner.exe")
    end
  end
end
