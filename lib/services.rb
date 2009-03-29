class ServiceError < StandardError
end

class BackgrounDRb::MetaWorker
  def update_mixable(options = {})
    mixable = 
      if options[:song_id]
        "song_id=#{options[:song_id]}"
      elsif options[:track_id]
        "track_id=#{options[:track_id]}"
      else
        raise ServiceError, "Unknown mixable type!"
      end

    url = URI.parse "#{options[:path]}/#{options[:user_id]}?#{mixable}&filename=#{options[:filename]}&length=#{options[:length]}"

    unless Net::HTTP.start(url.host, url.port) { |http| http.get(url.path + '?' + url.query) }.is_a?(Net::HTTPSuccess)
      raise ServiceError, "error while updating mixable: #$!"
    end
  end
end
