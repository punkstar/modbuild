require 'pathname'
require 'logger'
require 'builder'
require 'optparse'

module Meanbee
  module Modbuild
    VERSION = "1.0.0"

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
    
    class PackageXml
      def initialize(name, version, summary, description)
        @php_min = '5.2.0'
        @php_max = '6.0.0'
        @stability = 'stable'
        @license = 'Open Software License v3.0 (OSL-3.0)'
        @license_uri = 'http://opensource.org/licenses/OSL-3.0'
        @name = name
        @channel = 'community'
        @summary = summary
        @description = description
        @version = version
        @authors = []
        @depends_packages = []
        @depends_extensions = []
        @files = []
        
        add_extension_dependency 'Core', '', ''
      end
      
      def add_author(name, user, email)
        @authors << {
          :name => name,
          :user => user,
          :email => email
        }
      end
      
      def add_package_dependency(name, channel, min, max, files)
        @depends_packages << {
          :name => name,
          :channel => channel,
          :min => min,
          :max => max,
          :files => files
        }
      end
      
      def add_extension_dependency(name, min, max)
        @depends_extensions << {
          :name => name,
          :min => min,
          :max => max
        }
      end
      
      def add_file(name)
        @files << identify_file(name)
      end
      
      def to_string
        xml = Builder::XmlMarkup.new(:indent => 4)
        
        xml._ {
          xml.form_key "imtotallyirrelevant"
          xml.name @name
          xml.channel @channel
          xml.version_id {
            xml.version_ids 2
          }
          xml.summary @summary
          xml.description @description
          xml.license @license
          xml.license_uri @license_uri
          xml.version @version
          xml.stability @stability
          xml.notes @notes
          xml.authors {
            xml.names {
              @authors.each do |a|
                xml.name a[:name]
              end
            }
            xml.user {
              @authors.each do |a|
                xml.user a[:user]
              end
            }
            xml.email {
              @authors.each do |a|
                xml.email a[:email]
              end
            }
          }
          xml.depends_php_min @php_min
          xml.depends_php_max @php_max
          xml.depends {
            xml.package {
              [:name, :channel, :min, :max, :files].each do |key|
                @depends_packages.each do |pkg|
                  xml.tag!(key) {
                    xml.tag!(key, pkg[key])
                  }
                end
              end
            }
            
            xml.extension {
              [:name, :min, :max].each do |key|
                @depends_extensions.each do |pkg|
                  xml.tag!(key) {
                    xml.tag!(key, pkg[key])
                  }
                end
              end
            }
          }
          xml.contents {
            [:target, :path, :type].each do |key|
              xml.tag!(key) {
                @files.each do |f|
                  xml.tag!(key, f[key])
                end
              }
            end
            [:include, :ignore].each do |key|
              xml.tag!(key) {
                @files.length.times do |i|
                  xml.tag!(key)
                end
              }
            end
          }
        }
         
        return xml.target!
      end
      
      def identify_file(name)
        targets = {
          :magelocal     => 'app/code/local',
          :magecommunity => 'app/code/community',
          :magecore      => 'app/code/core',
          :mageetc       => 'app/etc',
          :magedesign    => 'app/design',
          :mageskin      => 'skin'
          # :mageweb is for everything else
        }
        
        file_type = (name =~ /\w*\.\w+$/) ? 'file' : 'dir'
        
        targets.each do |key, value|
          if name =~ /^#{value}/
            return {
              :target => key.to_s,
              :path   => name.gsub(/^#{value}\/?/, ''),
              :type   => file_type
            }
          end
        end
        
        return {
          :target => 'mageweb',
          :path => name,
          :type => file_type
        }
      end
    end
  end
end
