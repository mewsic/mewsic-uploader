require 'waveform'

class WaveformWorker < BackgrounDRb::MetaWorker
  set_worker_name :waveform_worker

  def generate(filename)
    return false unless File.exists? filename
    Adelao::Waveform.generate(filename)
  end
end

