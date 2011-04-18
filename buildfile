require "buildr/as3"

repositories.remote << "http://artifacts.devboy.org" << "http://repo2.maven.org/maven2"

THIS_VERSION =  "0.1.0"

desc "HydraP2P"
define "HydraP2P" do
  project.group = "org.devboy"
  project.version = THIS_VERSION
  compile.using :compc
  compile.options[:flexsdk] = FlexSDK.new("4.1.0.16076")
  compile.options[:other] = []
  compile.options[:other] << "-static-link-runtime-shared-libraries=true"
  compile.options[:other] << "-compiler.incremental=true"
  compile.options[:other] << "-target-player=10.1"
  package :swc
end