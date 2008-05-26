class DataFile < ActiveRecord::Base

  def self.save(data, name, directory)
    path = File.join(directory, name)
    File.open(path, 'wb') do |file|
      file.puts data.read
    end
  end
end
