require 'observer'
require 'hooks'

module Spree
  Base.class_eval do
    include Observer
  end
end
