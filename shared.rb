require 'fileutils'
require 'open-uri'
require 'shellwords'
require 'rubygems'
require 'zip'

def relative(*paths)
  File.join(__dir__, *paths)
end

def clean_mkdir(dir)
  path = relative(dir)
  FileUtils.rm_rf(path) if File.exist?(path)
  FileUtils.mkdir_p(path)
  path
end

def mkdir_if_not_exists(dir)
  path = relative(dir)
  FileUtils.mkdir_p(path) unless File.exist?(path)
  path
end

def clean_rm(file)
  path = relative(file)
  File.delete(path) if File.exist?(path)
  path
end

def download_file(url, target_file)
  mkdir_if_not_exists('tmp')
  file = relative('tmp', target_file)
  clean_rm(file)
  File.open(file, 'w') do |f|
    IO.copy_stream(open(url), f)
  end
  file
end

def extract_file(tar_bz2_path, target_path)
  file = File.join(File.expand_path(__dir__), tar_bz2_path)
  target = File.join(File.expand_path(__dir__), target_path)
  `tar -xjf #{file.shellescape} -C #{target.shellescape}`
end

def extract_zip(zip_path, target_path)
  Zip::File.open(zip_path) do |zip_file|
    zip_file.each do |f|
      fpath = File.join(target_path, f.name)
      zip_file.extract(f, fpath) unless File.exist?(fpath)
    end
  end
end

def mv(a, b)
  FileUtils.mv(relative(a), relative(b))
end

def run_cmd(cmd)
  result = system(cmd)
  unless result
    puts 'Executing command failed!'
    exit(1)
  end
end
