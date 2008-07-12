require 'waveform'

class WaveformWorker < BackgrounDRb::MetaWorker
  set_worker_name :waveform_worker
  set_no_auto_load true
  pool_size 10

  def generate(filename)
    return false unless File.exists? filename
    thread_pool.defer(filename) do |filename|
      Adelao::Waveform.generate(filename)
    end
  end
end

