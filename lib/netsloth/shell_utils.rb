require 'open3'

module Netsloth
  module ShellUtils
    #
    # run a shell command and yield each line
    # returns the exit code if it is non-zero, nil otherwise
    #
    def run(*cmd)
      options = if cmd.last.is_a?(Hash)
                  cmd.pop
                else
                  {}
                end
      if cmd.include?(nil)
        puts "ERROR: run() cannot accept nil arguments (received #{cmd.inspect})"
        return
      end
      cmd = cmd.map(&:to_s)
      exit_status = -1
      puts 'RUN %s' % cmd.join(' ') if options[:verbose]
      Open3.popen2e(ENV, *cmd) do |_stdin, out, thread|
        while (line = out.gets)
          yield line if block_given?
        end
        exit_status = thread.value.exitstatus.to_i
      end
      return nil unless exit_status != 0

      puts "ERROR: #{exit_status}" if options[:verbose]
      exit_status
    end

    def ensure_command(cmd)
      return if File.exist?(cmd)

      puts "ERROR: no such command #{cmd}"
      exit 1
    end
  end
end
