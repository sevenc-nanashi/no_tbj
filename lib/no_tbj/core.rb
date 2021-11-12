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
        puts "Please specify a command, 'install' or 'uninstall'.".minfo
        exit
      end
      case ARGV[0]
      when "install"
        install
      when "uninstall"
        uninstall
      else
        puts "Unrecognized command.".red
      end
    end

    def install
      bindir = RbConfig::CONFIG["bindir"]
      exepath = File.join(__dir__, +"main.exe")
      files = { skipped_exist: [], skipped_nobat: [], skipped_exception: [], installed: [] }
      force_level = ARGV.count("-f")
      Dir.glob(File.join(bindir, "*")).each do |file|
        next if File.directory?(file)
        next if File.fnmatch?("*.*", file)
        if File.exist?(file + ".exe") && force_level < 1
          next files[:skipped_exist] << file
        end
        next files[:skipped_nobat] << file unless File.exist?(file + ".bat") || File.exist?(file + ".cmd")

        begin
          FileUtils.cp(exepath, file + ".exe")
        rescue
          files[:skipped_exception] << file
        else
          files[:installed] << file
        end
      end
      files = files.map { |k, v| [k, v.map { |f| File.basename(f) }] }.to_h
      puts "Installed for {#{files[:installed].length}} files.".green
      puts "Skipped {#{files[:skipped_exist].length}} files because they already exist, use {-f} to overwrite.".minfo unless files[:skipped_exist].empty?
      puts "Skipped {#{files[:skipped_nobat].length}} files because they don't have a bat or cmd file.".minfo unless files[:skipped_nobat].empty?
      unless files[:skipped_exception].empty?
        puts "Skipped {#{files[:skipped_exception].length}} files because of an exception.".warn
        puts "Try adding {`.bat`} or {`.cmd`} to the end of the file name.".minfo
      end
    end

    def uninstall
      bindir = RbConfig::CONFIG["bindir"]
      files = { skipped_notnotbj: [], skipped_exception: [], uninstalled: [] }
      Dir.glob(File.join(bindir, "*.exe")).each do |file|
        next if File.directory?(file)
        is_no_tbj = false
        File.open(file, "rb") do |f|
          f.seek(-CHECKS.length, IO::SEEK_END)
          is_no_tbj = f.read(CHECKS.length) == CHECKS
        end
        if is_no_tbj
          begin
            FileUtils.rm(file)
          rescue
            files[:skipped_exception] << file
          else
            files[:uninstalled] << file
          end
        else
          files[:skipped_notnotbj] << file
        end
      end
      files = files.map { |k, v| [k, v.map { |f| File.basename(f) }] }.to_h
      puts "Uninstalled for {#{files[:uninstalled].length}} files.".success
      puts "Skipped {#{files[:skipped_notnotbj].length}} files because they aren't no_tbj's executable.".minfo unless files[:skipped_notnotbj].empty?
      unless files[:skipped_exception].empty?
        puts "Skipped {#{files[:skipped_exception].length}} files because of an exception.".minfo
        puts "Try adding {`.bat`} or {`.cmd`} to the end of the file name.".minfo
      end
    end
  end
end
