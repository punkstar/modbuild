require 'logger'

module Modbuild
  class Base
    attr_accessor :package_name, :package_version, :package_summary, :package_description
    
    def initialize(module_directory)
      @logger = Logger.new(STDERR)
      @logger.level = Logger::FATAL
      
      @module_location = module_directory
      @modman_location = File.join(module_directory, 'modman')
      @magento_location = File.join(module_directory, '..', '..')
      
      @package_name = 'Unspecified_Name'
      @package_version = '1.0.0'
      @package_summary = 'Unspecified package summary'
      @package_description = 'Unspecified package description'
      @package_files = []
    end
    
    def enable_debug
      @logger.level = Logger::DEBUG
    end
    
    def build
      @logger.debug "Module Directory: #{@module_location}"
      @logger.debug "Modman Directory: #{@modman_location}"
      @logger.debug "Magento Directory: #{@magento_location}"
      
      get_package_files
      
      @logger.debug 'Generating XML file..'
      package_xml = PackageXml.new @package_name, @package_version, @package_summary, @package_description
      
      @package_files.each do |file|
        package_xml.add_file file
      end
      
      return package_xml.to_string
    end
    
    def get_package_files
      # List all of the files related to this module, base on the modman contents
      modman_file = File.new @modman_location, 'r'

      @logger.debug "Reading modman file"
      while (line = modman_file.gets)
        line.chomp!
        
        if (line =~ /^\s*#/)
          @logger.debug "  Comment line: #{line}"
          if (/^#\s*(?<key>\w+)\s*:\s*(?<value>.*)$/ =~ line)
            @logger.debug "    Extracted: #{key} = #{value}"
            
            case key.downcase.to_sym
              when :name
                @package_name = value
              when :version
                @package_version = value
              when :summary
                @package_summary = value
              when :description
                @package_description = value
              else
                @logger.debug "      Unknown package variables"
            end
          end
        elsif (line =~ /^.*\s+.*$/)
          @logger.debug "  Line: #{line}"
          # local_file is the file in the .modman directory, the magento_file is where
          # the file is placed in the magento root
          local_file, magento_file = line.split ' '

          @logger.debug "    Local: #{local_file}"
          @logger.debug "    Magento: #{magento_file}"

          if local_file.match /\*$/
            local_file_directory = File.dirname local_file

            @logger.debug "      Identified as glob"
            @logger.debug "      Local file directory: #{local_file_directory}"

            Dir.glob(File.join(@module_location, local_file)).each do |f|
              @logger.debug "        Globbed file: #{f}"

              f_regex = Regexp.new "^#{@module_location}\/?"
              f_relative = f.gsub(f_regex, '')

              @logger.debug "        Adding: #{f_relative}"
              @package_files << f_relative
            end
          else
            @logger.debug "    Adding: #{magento_file}"
            @package_files << magento_file
          end
        end
      end
      
      modman_file.close
      
      return @package_files
    end
  end
end
