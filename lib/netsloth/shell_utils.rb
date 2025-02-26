require 'open3'

module Netsloth
  module ShellUtils
    #
    # run a shell command and yield each line
    # returns the exit code
    #
    def run(*cmd, verbose: false)
      cmd = cmd.map(&:to_s)
      exit_status = -1
      puts "RUN #{cmd.join(' ')}" if verbose
      Open3.popen2e(ENV, *cmd) do |_stdin, out, thread|
        while (line = out.gets)
          yield line if block_given?
        end
        exit_status = thread.value.exitstatus.to_i
      end

      puts "ERROR: #{exit_status}" if verbose && exit_status != 0
      exit_status
    end

    def ensure_command(cmd)
      return if File.exist?(cmd)

      puts "ERROR: no such command #{cmd}"
      exit 1
    end
  end
end
