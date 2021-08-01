require 'uri'

module Gemini

  module Helpers

    # Make sense of the URI and expands it with scheme etc. Note that it checks for
    # a local file (:scheme => "local").
    #
    # Example:
    #
    # {:type=>:uri, :link=>"gemini://gemini.circumlunar.space/docs/cheatsheet.gmi", :text=>"Cheat sheet", :scheme=>"gemini"}
    # {:type=>:uri, :link=>"./does-exist.png", :text=>"Image does exist", :scheme=>"local"}
    #
    # See the unit tests for more
    #
    def uri_info(gemini, path: nil)
      uri = URI(gemini[:link]) # validates too
      gemini[:scheme] =
        if not uri.scheme
          if File.exist?(gemini[:link])
            "local"
          else
            nil
          end
        else
          uri.scheme
        end

      gemini
    end
  end

end
