require 'yaml'
class Realm
  def initialize(file)
    @repo = YAML.load(File.read(file))
  end

  def settings
    @repo['settings']
  end

  def items
    repo['items']
  end

  def setting(name)
    settings&.dig(name)
  end

  attr_accessor :repo
end
