require 'open3'

module Netsloth
  module ShellUtils
    #
    # run a shell command and yield each line
    # returns the exit code if it is non-zero, nil otherwise
    #
    def run(*cmd)
      if cmd.last.is_a?(Hash)
        options = cmd.pop
      else
        options = {}
      end
      if cmd.include?(nil)
        puts "ERROR: run() cannot accept nil arguments (received #{cmd.inspect})"
        return
      end
      cmd = cmd.map &:to_s
      exit_status = -1
      if options[:verbose]
        puts "RUN %s" % cmd.join(' ')
      end
      Open3.popen2e(ENV, *cmd) do |stdin, out, thread|
        while line = out.gets do
          yield line if block_given?
        end
        exit_status = thread.value.exitstatus.to_i
      end
      if exit_status != 0
        if options[:verbose]
          puts "ERROR: #{exit_status}"
        end
        return exit_status
      else
        return nil
      end
    end

    def ensure_command(cmd)
      unless File.exist?(cmd)
        puts "ERROR: no such command #{cmd}"
        exit 1
      end
    end
  end
end
