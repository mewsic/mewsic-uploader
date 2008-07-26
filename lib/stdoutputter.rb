class StdOutputter
  attr_reader :output

  def run
    unless @status
      puts "Executing #{self.to_cmd}"
      @output = IO.popen("%s 2>&1" % self.to_cmd) { |pipe| pipe.read }
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
