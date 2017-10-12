#!/usr/bin/env ruby
# WARNING: nukes the entire tmp directory, and all binaries must be rebuilt!
require_relative 'shared'

FFMPEG_VERSION = '3.3.4'
FFMPEG_DOWNLOAD = "http://ffmpeg.org/releases/ffmpeg-#{FFMPEG_VERSION}.tar.bz2"
OUT_DIR = "ffmpeg-#{FFMPEG_VERSION}"

HEIF_DOWNLOAD = 'https://github.com/nokiatech/heif/archive/master.zip'

clean_mkdir('tmp')
puts 'Downloading ffmpeg...'
download_file(FFMPEG_DOWNLOAD, 'ffmpeg.tar.bz2')

puts 'Downloading heif...'
download_file(HEIF_DOWNLOAD, 'heif.zip')

puts 'Extracting ffmpeg...'
extract_file('tmp/ffmpeg.tar.bz2', 'tmp')
mv("tmp/#{OUT_DIR}", 'tmp/ffmpeg')

puts 'Extracting heif...'
extract_zip('tmp/heif.zip', 'tmp')
mv('tmp/heif-master', 'tmp/heif')

puts 'Building ffmpeg...'
cmd = <<~BASH
  cd #{relative('tmp/ffmpeg')} && 
    ./configure --enable-libx265 --enable-gpl &&
    make
BASH
run_cmd(cmd)

puts 'Building heif...'
cmd = <<~BASH
  cd #{relative('tmp/heif')} &&
    CXX=clang++ cmake . &&
    make
BASH
run_cmd(cmd)

puts 'Copying binaries...'
mkdir_if_not_exists('tmp/bin')
mv('tmp/ffmpeg/ffmpeg', 'tmp/bin')
mv('tmp/heif/Bins/writerapp', 'tmp/bin')

puts 'Done!'
