require 'fastthread'

class StdOutputter
  attr_reader :output

  def run
    return if @running
    @running = true
    @output = nil

    puts "Executing #{self.to_cmd}"
    @thread = Thread.new do
      @output = IO.popen("%s 2>&1" % self.to_cmd) { |pipe| pipe.read }
      @status = $?.exitstatus
      @running = false
      Thread.exit
    end

    return self
  end

  def running?
    @thread.alive?
  end

  def success?
    @status.zero?
  end
end
