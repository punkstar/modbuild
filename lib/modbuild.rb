$:.unshift File.dirname(__FILE__)

require 'pathname'
require 'logger'
require 'builder'
require 'optparse'

require 'modbuild/base'
require 'modbuild/package_xml'

module Modbuild
  VERSION = "1.0.1"
end
