#!/usr/bin/env ruby

# https://github.com/thibaudgg/rb-fsevent
require 'rb-fsevent'
require 'pathname'
require 'shellwords'

def bash(command)
  escaped_command = Shellwords.escape(command)
  system "bash -c #{escaped_command}"
end

if ARGV.length < 3
	puts "Usage: fsevent.rb DIR COMMAND [REPEATING_COMMAND]"
	exit
end

path, command, repeating = ARGV

path = File.expand_path(path)
if !File.directory?(path)
	puts "Not a valid path: [#{path}]"
	exit
end

# puts "\nWatching directory [#{path}] for changes, will run command [#{command}] and repeating command [#{repeating}]...\n"
puts "\nWatching directory [#{path}] for changes...\n"

options = {:latency => 0.5, :no_defer => true }

pathobj = Pathname.new path
fsevent = FSEvent.new
fsevent.watch path, options do |directories|

	subcommands  = []
	changedpaths = []

	directories.map{|directory|

		directory = Pathname.new directory
		relative = directory.relative_path_from pathobj
		relative = relative.to_s + '/'

		# Don't add Git metadata dirs, as they are ignored by rsync anyway
		next if relative[0,4] == ".git"

		subcommands.push(sprintf(repeating, relative))
		changedpaths.push << relative
	}

	next if subcommands.length == 0

	fullcommand = sprintf(command, subcommands.join(' '))
	puts "\nChanged paths: [" + changedpaths.join(', ') + ']'

	# Run the command
	bash fullcommand
end
fsevent.run

