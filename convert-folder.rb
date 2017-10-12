#!/usr/bin/env ruby
require_relative 'shared'
require 'optparse'
require 'pry'

@input_folder = nil
@output_folder = nil

OptionParser.new do |parser|
  parser.on('-i', '--input-folder FOLDER', 'Input folder of tiff images') { |f| @input_folder = f }
  parser.on('-o', '--output-folder FOLDER', 'Output folder of hvec images') { |f| @output_folder = f }
  parser.on('-h', '--help', 'Prints help') do
    puts parser
    exit
  end
end.parse!

if @input_folder.nil? || @output_folder.nil?
  $stderr.puts 'Missing required argument!'
  exit(1)
end

FileUtils.mkdir_p(@output_folder) unless File.exist?(@output_folder)

def is_tiff?(file)
  ext = file.split('.').last.downcase
  ext == 'tif' || ext == 'tiff'
end

def convert(file)
  basename = File.basename(file).split('.')
  basename.pop
  basename = basename.join('.')

  out = File.join(@output_folder, "#{basename}.h")

  bin = relative('tmp/bin/ffmpeg')
  cmd = <<~BASH
    #{bin} \
      -i #{file} -c:v libx265 -crf 12 -pix_fmt
  BASH
end


Dir[File.join(@input_folder, '*')].each do |f|
  next unless is_tiff?(f)
  puts f
end
