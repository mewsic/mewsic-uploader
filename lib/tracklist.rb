require 'rexml/document'

class TracklistError < StandardError
end

class Tracklist < Array
  # <song>
  #   <track id="2" volume="0.5" balance="0" filename="7f095f59b1a167a01822e098336af509.mp3"/>
  #   <track id="15" volume="0.5"  balance="0" filename="05dacfb908ee316529a363dec51afa1e.mp3"/>
  # </song>
  
  def initialize(xml)
    doc = REXML::Document.new(xml)
    
    raise TracklistError, 'invalid XML' if doc.root.nil? || doc.root.name != 'song'

    doc.root.elements.each('track') do |track|
      self.push Track.new(track.attributes.symbolize_keys)
    end
  end
end

class Track
  Attributes = [:id, :filename, :volume, :balance]

  def initialize(attributes)
    @attributes = attributes
    @attributes.assert_valid_keys *Attributes

    unless Attributes.all? { |attr| @attributes.has_key?(attr) && !@attributes[attr].blank? }
      raise TracklistError, 'incomplete track'
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

