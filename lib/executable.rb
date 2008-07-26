class Executable
  attr_reader :status

  def run
    unless @status
      puts "Executing #{self.to_cmd}"
      Process.wait(fork { exec(self.to_cmd) })
      @status = $?.exitstatus
    end
    return self
  end

  def success?
    @status.zero?
  end

  def error
    @status = -1
  end
end
