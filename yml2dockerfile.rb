require 'pp'
require 'yaml'

def rmrf(line)
  cmd = "find #{line.shift}"
  arg = line.map{|v| '"'+v['name']+'"'}.join(' -o -iname ')
  return "#{cmd} -iname #{arg} | grep -v '/proc/' | xargs rm -rf"
end

def debug(yml)
  puts "RUN apk --update stats"
  yml.each do | line |
    key = line.keys[0]
    val = line[key]

    case key.downcase
    when 'env'
      puts "ENV #{val}"
    when 'apk', 'dev'
      puts "RUN apk add #{val}"
    when 'copy'
      puts "COPY #{val} /"
    when 'run'
      puts "RUN #{val}"
    when 'rmrf'
      puts "RUN #{rmrf(val)}"
    else
      raise "ERROR"
    end
  end
end

def release(yml)
  envs = []
  apks = []
  devs = []
  cps = []
  runs = []

  yml.each do | line |
    key = line.keys[0]
    val = line[key]

    case key.downcase
    when 'env'
      envs << val
    when 'apk'
      apks << val
    when 'dev'
      devs << val
    when 'copy'
      cps << val
    when 'run'
      runs << val
    when 'rmrf'
      runs << rmrf(val)
    end
  end

  puts "ENV #{envs.join(" \\\n    ")}"
  puts "COPY #{cps.join(' ')} /"

  runs.unshift("apk add --update #{apks.join(' ')}",
    "apk add --virtual build-builddeps #{devs.join(' ')}")
  runs << "apk del --purge build-builddeps"
  runs << "find / -name apk | xargs rm -rf"
  runs << "rm -rf /tmp/*"
  puts "RUN #{runs.join(" \\\n    && ")}"
end


if __FILE__ == $0
  release = (ARGV[0] == 'release')
  yml = YAML.load(STDIN)

  puts "FROM #{yml.shift}"
  if release
    release(yml)
  else
    debug(yml)
  end
end
