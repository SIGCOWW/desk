#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
# compile.rb builder resultfile
#
#
require 'yaml'
require 'open3'
require 'base64'
require 'fileutils'
require 'securerandom'

TMPDIR = 'tmp' + SecureRandom.hex(8)
ERR_MSG_FILE = SecureRandom.hex(8) + '.re'


def preprocess(catalog, builder)
	catalog.each_value do | value |
		next if value.nil?
		value.each do | filename |
			txt = File.read("articles/#{filename}").gsub(/\r\n/, "\n")
			txt = txt.gsub(/^(\/\/\w+raw(?:\[\S+?\])*{\s*)(.+?)(\s*\/\/})$/m) { $1 + Base64.encode64($2).delete('=') + $3 }
			txt.gsub!(/^@<author>{.+}$/, '') if (builder === 'epub')
			File.write(filename, txt)
		end
	end

	return unless builder === "epub"
	Dir.glob("./images/*/*").each do | file |
		next if File.ftype(file) === 'file'
		next if File.ftype(file) === 'directory' && File.dirname(file) === 'html'
		puts file
		FileUtils.rm_rf(file, :secure => true)
	end
end

def convert(catalog, builder)
	def margin?(path)
		stdout, stderr, status = Open3.capture3("convert #{path} -crop 1x1+0+0 -format \"%[fx:r],%[fx:g],%[fx:b],%[fx:a]\" info:")
		rgba = stdout.split(',')
		return (rgba[3] === '0' || (rgba[0] === '1' && rgba[1] === '1' && rgba[2] === '1'))
	end

	def for_latex(ext, src, dst_id)
		case ext
		when '.pdf'
			system("pdfcrop.sh #{src} #{dst_id}.pdf")
		when '.png'
			prefix = margin?(src) ? "- | convert -trim +repage - " : ""
			system("convert #{src} \\( +clone -alpha opaque -fill white -colorize 100% \\) +swap -geometry +0+0 -compose Over -composite -alpha off #{prefix}#{dst_id}.png")
		when '.jpg', '.jpeg'
			system("convert -auto-orient -strip #{src} #{dst_id}.jpg")
		end
	end

	def for_html(ext, src, dst_id)
		case ext
		when '.pdf'
			system("convert -antialias -density 300 #{src} #{dst_id}.png")
			system("mogrify -trim +repage #{dst_id}.png") if margin?(dst_id + '.png')
		when '.png'
			system("convert -trim +repage #{src} #{dst_id}.png") if margin?(src)
		when '.jpg', '.jpeg'
			system("convert -auto-orient -strip #{src} #{dst_id}.jpg")
			FileUtils.rm_f(src)
		end
	end

	catalog.each_value do | value |
		next if value.nil?
		value.each do | v |
			name = v.gsub(/.[a-zA-Z0-9]+$/, '')
			Dir.glob("./images/#{name}/*").each do | file |
				path = "./images/#{builder}/#{name}"
				FileUtils.mkdir_p(path)

				ext = File.extname(file).downcase
				dst_id = "#{path}/" + File.basename(file).gsub(/.[a-zA-Z0-9]+$/, '')
				if builder === 'latex'
					for_latex(ext, file, dst_id)
				elsif builder === 'html'
					for_html(ext, file, dst_id)
				end
			end
		end
	end
end

def compile(catalog, builder)
	catalog = Marshal.load(Marshal.dump(catalog))
	FileUtils.mv('catalog.yml', TMPDIR)

	maker = builder
	builder = 'pdf' if maker === 'pubpdf'

	code = nil
	5.times do | i |
		File.write('catalog.yml', catalog.to_yaml)
		catalog.each_value do | value |
			next if value.nil? || value.empty?
			value.each { |f| system("review-preproc --replace #{f}") }
		end

		env = (maker === 'pubpdf') ? 'env ONESIDE=1 ' : ''
		stdout, stderr, status = Open3.capture3("#{env}review-#{builder}maker config.yml")
		STDOUT.print(stdout)
		STDERR.print(stderr)
		code = status.exitstatus

		errors = stderr.scan(/compile error in (.+?)\.(?:re|tex)/).map{|v| v[0]+'.re'}
		break if errors.length === 0

		puts "RETRY"
		catalog.each_key do | key |
			next if catalog[key].nil?
			catalog[key].select!{ |v| not errors.include?(v) }
		end
		catalog.delete_if { |k, v| v.nil? || v.empty? }
		break if catalog.empty?

		first = catalog.first
		catalog[first[0]].unshift(ERR_MSG_FILE) if !first.nil? && !catalog[first[0]].include?(ERR_MSG_FILE)
		File.write(ERR_MSG_FILE, "= WARNING#{i}\n//emlist{\n#{stderr}//}")
	end

	return code
end


if __FILE__ == $0
	exit 1 if ARGV.length != 2
	catalog = YAML.load_file('catalog.yml')
	FileUtils.mkdir_p(TMPDIR)
	FileUtils.cp_r('./images', TMPDIR, :preserve => true)

	begin
		preprocess(catalog, ARGV[0])
		convert(catalog, ARGV[0] === 'epub' ? 'html' : 'latex')
		status = compile(catalog, ARGV[0])
		File.write(ARGV[1], status / 256)
	rescue => e
		p e.class
		p e.message
		p e.backtrace
	end

	# Recovery
	FileUtils.mv("#{TMPDIR}/catalog.yml", './') if FileTest.exist?("#{TMPDIR}/catalog.yml")
	FileUtils.rm_rf('./images', :secure => true)
	FileUtils.mv("#{TMPDIR}/images", './images')
	FileUtils.rm_f(ERR_MSG_FILE)
	FileUtils.rm_rf(TMPDIR, :secure => true)
	catalog.each_value do | value |
		next if value.nil?
		value.each{ |v| FileUtils.rm_f(v) }
	end
end
