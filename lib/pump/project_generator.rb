require "fileutils"

class ProjectGenerator
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def generate
    source = "#{File.dirname(__FILE__)}/templates/app"
    FileUtils.copy_entry(source, path)
  end
end
