
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

teapot_version "1.0.0"

define_target "build-make" do |target|
	target.provides "Build/Make" do
		define "configure.generate-makefile", Rule do
			parameter :prefix
			
			input :configure_file, implicit: true do |arguments|
				File.join(arguments[:prefix], "configure")
			end
			
			output :make_file, implicit: true do |arguments|
				File.join(arguments[:prefix], "Makefile")
			end
		end
		
		define "make.install", Rule do
			parameter :prefix
			
			input :make_file, implicit: true do |arguments|
				FSO::Files::Paths.new(arguments[:prefix].full_path, "Makefile")
			end
			
			output :package_files
			
			apply do |arguments|
				destination_prefix = arguments[:prefix]
				
				run!("make", "-j", FSO::Pool::processor_count, chdir: destination_prefix.full_path)
				run!("make", "install", chdir: destination_prefix.full_path)
				
				arguments[:package_files].each do |path|
					fs.touch path
				end
			end
		end
	end
end
