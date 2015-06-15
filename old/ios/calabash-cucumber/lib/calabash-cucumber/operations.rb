require 'calabash-cucumber/core'
require 'calabash-cucumber/tests_helpers'
require 'calabash-cucumber/keyboard_helpers'
require 'calabash-cucumber/keychain_helpers'
require 'calabash-cucumber/wait_helpers'
require 'calabash-cucumber/launcher'
require 'net/http'
require 'json'
require 'set'
require 'calabash-cucumber/version'
require 'calabash-cucumber/date_picker'
require 'calabash-cucumber/ipad_1x_2x'
require 'calabash-cucumber/utils/logging'

module Calabash
  module Cucumber

    # A module for wrapping the public APIs of this gem.
    module Operations

      include Calabash::Cucumber::Logging
      include Calabash::Cucumber::Core
      include Calabash::Cucumber::TestsHelpers
      include Calabash::Cucumber::WaitHelpers
      include Calabash::Cucumber::KeyboardHelpers
      include Calabash::Cucumber::KeychainHelpers
      include Calabash::Cucumber::DatePicker
      include Calabash::Cucumber::IPad

      def self.extended(base)
        if (class << base; included_modules.map(&:to_s).include?('Cucumber::RbSupport::RbWorld'); end)
          unless instance_methods.include?(:embed)
            original_embed = base.method(:embed)
            define_method(:embed) do |*args|
              original_embed.call(*args)
            end
          end
        end
      end

    end
  end
end
