#!/usr/bin/ruby

# USAGE: ruby /Users/steve/Dropbox/BASH\ Scripts/housekeep.rb /Users/steve/Downloads
#
# 'source' = /Users/steve/Downloads		(same as 'pathonly')

#					                   	F I L E                                     		D I R E C T O R Y							D I R E C T O R Y (with period in name)
# 										/Users/steve/Downloads/About\ Downloads.pdf       	/Users/steve/Downloads/wordpress			/Users/steve/Downloads/bootstrap-4.0.0-alpha.6-dist

# 'pathonly' =							/Users/steve/Downloads                            	/Users/steve/Downloads						/Users/steve/Downloads
# 'filename' =							About Downloads.pdf                               	wordpress									bootstrap-4.0.0-alpha.6-dist
# 'name'     =							About Downloads                                   	wordpress									bootstrap-4.0.0-alpha.6-dist		(Initially set to 'bootstrap-4.0.0-alpha' which is incorrect)
# 'ext'      =							.pdf                                               	wordpress									bootstrap-4.0.0-alpha.6-dist		(Initially set to '.6-dist' which is incorrect)
#
# 'treat_as_files' = An array of file extensions that are associated with entires that are (maybe) directories but need to be treated as files
# 'exclude' = An array of entries to ignore

require 'fileutils'
require 'socket'
require 'date'
require 'time'

source = ARGV[0]
if source[source.length - 1, 1] == "/"
	source = source[0, source.length - 1]	# Remove trailing forward slash for consistency if it exists
end

treat_as_files = Array.new(['.app', '.download', '.kext', '.mpkg', '.pkg', '.prefpane', '.rtfd'])
exclude = Array.new(['.', '..', '.DS_Store', '.localized', 'Icon?'])

def check_duplicate (target, name, ext, is_file)

	if is_file
		if File.exist?("#{target}/#{name}#{ext}")
			x=1
			while File.exist?("#{target}/#{name}_#{x}#{ext}") do
				x+=1
			end
			new_entry = "#{target}/#{name}_#{x}#{ext}"
		else
			new_entry = "#{target}/#{name}#{ext}"
		end
	else
		if File.exist?("#{target}/#{name}")
			x=1
			while File.exist?("#{target}/#{name}_#{x}") do
				x+=1
			end
			new_entry = "#{target}/#{name}_#{x}"
		else
			new_entry = "#{target}/#{name}"
		end

	end

	return new_entry

end

def write_log (log, message)
	processed = Time.now
	.strftime("%d-%m-%Y %H:%M:%S")
	File.open("#{log}", 'a') do |f|
    	f.write "[" + Date.parse(processed).strftime("%d-%m-%Y") + " " +  Time.parse(processed).strftime("%H:%M:%S") + "] " + message
	end
	return processed
end

logfile = '/Volumes/CrashPlan Restore/housekeep-' + Socket.gethostname.downcase + '.log'

write_log(logfile,  "STARTED: #{source}" + "\n")

Dir.foreach (source) do |i|
	next if exclude.include? i

	pathonly =  File.dirname("#{source}/#{i}")
	filename = File.basename("#{source}/#{i}")
	name = File.basename("#{source}/#{i}", File.extname("#{source}/#{i}") )
	ext = File.extname("#{source}/#{i}")

	if File.directory? ("#{source}/#{i}")
		if treat_as_files.include? File.extname ("#{source}/#{i.downcase}")
			type = "FILE"
		else
			type = "DIRECTORY"
			name = "#{filename}"
			ext = "#{filename}"
		end
	elsif File.file? ("#{source}/#{i}")
		type = "FILE"
	end

	if type == "FILE"
		new_entry = ''
		case ext.downcase
			# _Applications
			when '.app', '.exe', '.kext', '.prefpane'
				new_entry = check_duplicate("#{pathonly}/_Applications", name, ext, true)


			# _Archives
			when '.bz2', '.download', '.dmg', '.gz', '.hqx', '.iso', '.mpkg', '.pkg', '.rar', '.tar', '.tgz'
				if "#{ext.downcase}" != ".download"
					new_entry = check_duplicate("#{pathonly}/_Archives", name, ext, true)
				else
					write_log(logfile, "IGNORED FILE " + "#{source}/#{i}" + " AS PER RULES " + "\n")
				end


			# _Databases
			when '.sql'
				new_entry = check_duplicate("#{pathonly}/_Databases", name, ext, true)


			# _Documents
			when '.csv', '.doc', '.docx', '.numbers', '.pages', '.pdf', '.rtf', '.rtfd', '.txt', '.xls', '.xlsx'
				if "#{filename}" != "About Downloads.pdf"
					new_entry = check_duplicate("#{pathonly}/_Documents", name, ext, true)
				else
					write_log(logfile, "IGNORED FILE " + "#{source}/#{i}" + " AS PER RULES " + "\n")
				end


			# _Images
			when '.gif', '.jpg', '.jpeg', '.mov', '.m4v', '.png', '.psd', '.tif', '.tiff'
				new_entry = check_duplicate("#{pathonly}/_Images", name, ext, true)


			# _Sound
			when '.mp3', '.m4a'
				new_entry = check_duplicate("#{pathonly}/_Sound", name, ext, true)


			# _Source
			when '.css', '.js', '.htm', '.html', '.php', '.scpt', '.sh', '.xml'
				new_entry = check_duplicate("#{pathonly}/_Source", name, ext, true)


			# _Source
			when '.zip'
				new_entry = check_duplicate("#{pathonly}/_ZIPS", name, ext, true)


			# _Miscellaneous
			else
				new_entry = check_duplicate("#{pathonly}/_Miscellaneous", name, ext, true)
		end

		if new_entry != ''
			FileUtils.mv "#{source}/#{i}", new_entry
			time_stamp = write_log(logfile, "MOVED FILE " + "#{source}/#{i}" + " TO " + new_entry + "\n")
			FileUtils.ln_s new_entry, "/Volumes/CrashPlan\ Restore/Housekeep\ Links/#{i}" + " {" + Date.parse(time_stamp).strftime("%Y%m%d") + "-" +  Time.parse(time_stamp).strftime("%H%M%S") + "}", :force => true
		end

	elsif type == "DIRECTORY"
		if "#{i[0, 1]}" != "_"
			new_entry = check_duplicate("#{pathonly}/_Folders", name, ext, false)
			FileUtils.mv "#{source}/#{i}", new_entry
			time_stamp = write_log(logfile, "MOVED DIRECTORY " + "#{source}/#{i}" + " TO " + new_entry + "\n")
			FileUtils.ln_s new_entry, "/Volumes/CrashPlan\ Restore/Housekeep\ Links/#{i}" + " {" + Date.parse(time_stamp).strftime("%Y%m%d") + "-" +  Time.parse(time_stamp).strftime("%H%M%S") + "}", :force => true
		else
			write_log(logfile, "IGNORED DIRECTORY " + "#{source}/#{i}" + " AS PER RULES " + "\n")
		end

	end

end

write_log(logfile, "FINISHED: #{source}" + "\n\n")
