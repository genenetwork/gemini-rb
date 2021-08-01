require 'uri'

module Gemini

  module Helpers

    # Make sense of the URI and expands it with scheme etc. E.g.
    # {:type=>:uri, :link=>"gemini://gemini.circumlunar.space/docs/cheatsheet.gmi", :text=>nil, :scheme=>"gemini", :host=>"gemini.circumlunar.space", :path=>"/docs/cheatsheet.gmi"}
    def uri_info(gemini)
      uri = URI(gemini[:link]) # validates too
      gemini[:scheme] =
        if not uri.scheme
          if File.exist?(gemini[:link])
            :exists
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
