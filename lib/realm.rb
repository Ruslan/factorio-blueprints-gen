require 'yaml'
class Realm
  def initialize(file, default_realm = nil)
    @repo = YAML.load(File.read(file))
    @default_realm = default_realm
  end

  def settings
    @repo['settings']
  end

  def items
    if @default_realm
      @default_realm.items.merge(repo['items'])
    else
      repo['items']
    end
  end

  def setting(name)
    settings&.dig(name)
  end

  attr_accessor :repo
end
