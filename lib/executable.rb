class Executable
  attr_reader :status

  def run
    return unless @status == :idle

    @status = :running
    puts "Executing #{self.to_cmd}"
    @pid = fork { exec(self.to_cmd) }

    return self
  end

  def running?
    if @pid && Process.wait(@pid, Process::WNOHANG)
      @pid = nil
      @status = File.exists?(@output) ? :finished : :error
    end

    @status == :running
  end

  def success?
    @status == :finished
  end
end
