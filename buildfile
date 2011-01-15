require "./../BuildrAs3/.buildr/actionscript.rb"

require "release.rb" if File.exists? "release.rb"

repositories.remote << "http://artifacts.devboy.org"
flex_sdk = Buildr::Compiler::Flex4SDK.new("4.1.0.16076")

desc "HydraP2P"
define "HydraP2P" do
  project.group = "org.devboy"
  project.version = "0.1"
  compile.using(:compc)
  compile.options[:flexsdk] = flex_sdk
  compile.options["static-link-runtime-shared-libraries"] = "true"
  compile.options["compiler.incremental"] = "true"
  compile.options["local-fonts-snapshot"] = "#{flex_sdk.home}/frameworks/localFonts.ser"
  compile.options["target-player"] = "10.1"
  package :swc
end