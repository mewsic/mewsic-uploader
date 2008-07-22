
class TracklistError < StandardError
end

class Tracklist < Array
  def initialize(tracks)
    self.replace(tracks.values.map { |attributes| Track.new(attributes.symbolize_keys) })
  end
end

class Track
  Attributes = [:id, :filename, :volume, :balance]

  def initialize(attributes)
    @attributes = attributes
    @attributes.assert_valid_keys *Attributes

    unless Attributes.all? { |attr| @attributes.has_key?(attr) && !@attributes[attr].blank? }
      raise TracklistError, "incomplete track (attributes: #{@attributes.inspect})"
    end

    @attributes[:filename] = File.join(MP3_OUTPUT_DIR, @attributes[:filename])
    unless File.exists? @attributes[:filename]
      raise TracklistError, 'file not found'
    end

    @attributes[:id] = @attributes[:id].to_i
    @attributes[:volume] = @attributes[:volume].to_f
    @attributes[:balance] = @attributes[:balance].to_f
  end

  private
    def method_missing(meth, *args, &block)
      if @attributes.has_key? meth
        @attributes[meth]
      else
        super(meth, *args, &block)
      end
    end
end
