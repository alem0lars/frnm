require "fileutils"

def rename(min_idx, max_idx, add_value, pattern, noop: false)
  puts "Renaming: from #{min_idx} to #{max_idx} adding #{add_value} (test mode: #{noop})"
  Dir[pattern]
    .map { |f| [f, f] }
    .map { |fo, fn| [fo, File.basename(fn)] }
    .select { |fo, fn| fn[0..1].to_i >= min_idx && fn[0..1].to_i <= max_idx }
    .sort { |(_, fn1), (_, fn2)| fn1 <=> fn2 }
    .map { |fo, fn| [fo, "TMP_#{(fn[0..1].to_i + add_value).to_s.rjust(2, "0")}#{fn[2..-1]}"] }
    .each { |fo, fn| FileUtils.mv(fo, File.join(File.dirname(fo), fn), noop: noop, verbose: true) }
end

def remove_tmp_prefix(pattern, noop: false)
  puts "Removing tmp prefix (test mode: #{noop})"
  Dir[pattern]
    .map { |f| [f, f] }
    .map { |fo, fn| [fo, File.basename(fn)] }
    .select { |fo, fn| fn =~ /^TMP\_/ }
    .map { |fo, fn| [fo, fn.gsub(/^TMP\_/, "")] }
    .each { |fo, fn| FileUtils.mv(fo, File.join(File.dirname(fo), fn), noop: noop, verbose: true) }
end

def swap(min_idx, max_idx, add_value, pattern, noop: false)
  rename(min_idx, max_idx, add_value, pattern, noop: noop)
  rename(min_idx + add_value, max_idx + add_value, -add_value, pattern, noop: noop)
  remove_tmp_prefix(pattern, noop: noop)
end

swap(ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_i, ARGV[3].to_i,
     noop: ARGC < 4 || !(ARGV[4] =~ /^reallydoit$/))
