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


def preprocess(catalog)
	list = [ 'tabletabooular', 'demath' ]
	catalog.each_value do | value |
		next if value.nil?
		value.each do | filename |
			txt = File.read("articles/#{filename}")
			list.each do | l |
				txt = txt.gsub(/^(\/\/#{l}(?:\[\S+?\])*{\s*)(.+?)(\s*\/\/})$/m) { $1 + Base64.encode64($2).delete('=') + $3 }
			end

			File.write(filename, txt)
		end
	end
end

def convert(catalog, builder)
	catalog.each_value do | value |
		next if value.nil?
		value.each do | v |
			name = v.gsub(/.[a-zA-Z0-9]+$/, '')
			Dir.glob("./images/#{name}/*").each do | file |
				path = "./images/#{builder}/#{name}"
				FileUtils.mkdir_p(path)

				dest = "#{path}/" + File.basename(file).gsub(/.[a-zA-Z0-9]+$/, '')
				case File.extname(file)
				when '.pdf' then
					if builder === 'latex'
						system("pdfcrop #{file} #{dest}.pdf")
					elsif builder === 'html'
						system("convert -trim -density 300 #{file} #{dest}.png")
					end
				when '.png' then
					if builder === 'latex'
						system("convert -trim #{file} \( +clone -alpha opaque -fill white -colorize 100% \) +swap -geometry +0+0 -compose Over -composite -alpha off #{dest}.png")
					end
				when '.jpg' then
					system("convert -auto-orient -strip #{file} #{dest}.jpg")
				end
			end
		end
	end
end

def compile(catalog, builder)
	catalog = Marshal.load(Marshal.dump(catalog))
	FileUtils.mv('catalog.yml', TMPDIR)

	code = nil
	5.times do | i |
		File.write('catalog.yml', catalog.to_yaml)
		catalog.each_value do | value |
			next if value.nil? || value.empty?
			value.each { |f| system("review-preproc --replace #{f}") }
		end

		stdout, stderr, status = Open3.capture3("review-#{builder}maker config.yml")
		STDOUT.print(stdout)
		STDERR.print(stderr)
		code = status.exitstatus

		errors = stderr.scan(/compile error in (.+?)\.(?:re|tex)/).map{|v| v[0]+'.re'}
		break if errors.length === 0

		puts('RETRY')
		catalog.each_key do | key |
			next if catalog[key].nil?
			catalog[key].select!{ |v| not errors.include?(v) }
		end
		catalog.delete_if { |k, v| v.nil? || v.empty? }
		break catalog.empty?

		first = catalog.first
		catalog[first[0]].unshift(ERR_MSG_FILE) if !first.nil? && !catalog[first[0]].include?(ERR_MSG_FILE)
		File.write(ERR_MSG_FILE, "= WARNING#{i}\n//emlist{{\n#{stderr}//}}")
	end

	return code
end


if __FILE__ == $0
	exit 1 if ARGV.length != 2
	catalog = YAML.load_file('catalog.yml')
	FileUtils.mkdir_p(TMPDIR)

	begin
		preprocess(catalog)
		convert(catalog, ARGV[0] === 'pdf' ? 'latex' : (ARGV[0] === 'epub' ? 'html' : ARGV[0]))
		status = compile(catalog, ARGV[0])
		File.write(ARGV[1], status / 256)
	rescue => e
		p e.class
		p e.message
		p e.backtrace
	end

	# Recovery
	FileUtils.mv("#{TMPDIR}/catalog.yml", './') if FileTest.exist?("#{TMPDIR}/catalog.yml")
	FileUtils.rm_rf('./images/latex', :secure => true)
	FileUtils.rm_rf('./images/html', :secure => true)
	FileUtils.rm_f(ERR_MSG_FILE)
	FileUtils.rm_rf(TMPDIR, :secure => true)
	catalog.each_value do | value |
		next if value.nil?
		value.each{ |v| FileUtils.rm_f(v) }
	end
end
