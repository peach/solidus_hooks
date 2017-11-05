require 'solidus_hooks/observer'
require 'solidus_hooks/hooks'

module Spree
  Base.class_eval do
    include SolidusHooks::Observer
  end
end
