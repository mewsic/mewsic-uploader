require 'find'
require 'fileutils'
Find.find('./') do |path|
  if File.basename(path) == '.svn'
    FileUtils.remove_dir(path, true)
    Find.prune
  end
end
