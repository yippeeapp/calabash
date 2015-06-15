module Calabash

  # A public API for entering text.
  module Text
    include Calabash::Utility

    # Enter `text` into the currently focused view.
    #
    # @param [String] text The text to type.
    # @raise [RuntimeError] if the text cannot be typed.
    def enter_text(text)
      Device.default.enter_text(text)
    end

    # Enter `text` into `query`.
    # @see Calabash::Text#enter_text
    #
    # @param [String] text The text to type.
    # @param query A query describing the view to enter text into.
    def enter_text_in(query, text)
      _enter_text_in(query, text)
    end

    # @!visibility private
    def _enter_text_in(view, text)
      abstract_method!
    end
  end
end
