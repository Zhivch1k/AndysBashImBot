# frozen_string_literal: true

require 'net/http'
require 'cgi'

class BashQuote
  def run
    quote_id = 0
    quote_body = ""

    loop do
      quote_id, uri = find_valid_post()
      
      post_body = Net::HTTP.get(uri)

      quote_body = get_text_from_post_and_decode_it(post_body)

      break if quote_body.length < 200
    end

    @id = "Цитата №" + quote_id.to_s
    @body = quote_body
    @link = "https://bash.im/quote/" + quote_id.to_s
  end

  def get_text_from_post_and_decode_it(body)
    rare = body[/meta property="og:description" content=".*/]
    medium_well = rare[/content=".*"/]
    well_done = medium_well[/(?<=\").+?(?=\")/]
    
    return CGI.unescapeHTML(well_done).force_encoding('UTF-8')
  end

  def find_valid_post
    quote_id = rand(400000..460000)

    url = "https://bash.im/quote/" + quote_id.to_s

    uri = URI(url)

    response = Net::HTTP.get_response(uri)
    
    if response.is_a?(Net::HTTPSuccess)
      return quote_id, uri
    else
      find_valid_post()
    end
  end

  def get_id
    return @id
  end

  def get_body
    return @body
  end

  def get_link
    return @link
  end
end
