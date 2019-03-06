
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

require 'etc'

teapot_version "3.0"

define_target "build-make" do |target|
	target.provides "Build/Make" do
		define Rule, "configure.generate-makefile" do
			parameter :prefix
			
			input :configure_file, implicit: true do |arguments|
				Path.join(arguments[:prefix], "configure")
			end
			
			output :make_file, implicit: true do |arguments|
				Path.join(arguments[:prefix], "Makefile")
			end
		end
		
		define Rule, "make.install" do
			parameter :prefix
			
			input :make_file, implicit: true do |arguments|
				Path.join(arguments[:prefix], "Makefile")
			end
			
			output :package_files
			
			apply do |arguments|
				destination_prefix = arguments[:prefix]
				
				run!("make", "-j", Etc.nprocessors.to_s, chdir: destination_prefix)
				run!("make", "install", chdir: destination_prefix)
				
				Array(arguments[:package_files]).each do |path|
					touch path
				end
			end
		end
	end
end
