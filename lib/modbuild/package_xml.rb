module Modbuild
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
