require 'find'
require 'fileutils'


class Clear
  def self.all(start_path, prefix)
    begin
      Find.find(start_path) do |path|
        reg = Regexp.new("#{prefix}", true)
        if File.basename(path) =~ reg
          
          puts "trovato il file #{File.basename(path)}"
          FileUtils.remove_file(path, true)
          
          puts " -- rimosso"
          
          Find.prune
        end
      end
    rescue => ex
      #skip
    end
  end
  
  
end