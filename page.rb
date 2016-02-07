require 'mechanize'
require 'uri'
class Page
  attr_accessor :uri,:links ,:inputs ,:document

  def initialize(url)
    url+= "/" if url[-1,1] != '/'
    @uri = URI(url)
    @inputs = 0
    @links = []
  end

  def get_page(url = nil)
    url ||= @uri.to_s
    mechanize = Mechanize.new
    page = mechanize.get url
    @document = Nokogiri::HTML(page.body, "UTF-8")
  end

  def get_refers
    @document.css('a').each do |link|
      if valid_link?(link['href'])
        full_url = construct_full_link(link['href'])
        @links << full_url if full_url != uri.to_s and depth(full_url) < 4
      end
    end
    @links = @links.to_set
  end

  def get_inputs
    @inputs += @document.css('input').size
  end


  def valid_link?(link)
    !(link.include?('://') and !link.include?(@uri.host.to_s)) and
        link != @uri.to_s and
        depth(@uri.to_s) < 4 and
        good_link?(link) and
        construct_full_link(link) =~ /\A#{URI::regexp(['http', 'https'])}\z/ unless link.nil?
  end

  def construct_full_link(string)
    string += '/' if string[-1,1] != "/"
    return string if string =~ /\A#{URI::regexp(['http', 'https'])}\z/
    URI.join(uri.to_s, string).to_s
  end

  def get_metadata
    @document = get_page
    get_refers
    get_inputs
    self
  end

  def depth(full_url)
    URI(full_url).path.split('/').reject(&:empty?).size
  end

  def good_link?(link)
    ['mailto:','javascript:','#','facebook.com','twitter.com','pinterest.com','instagram.com','vimeo.com','linkedin.com','youtube.com'].each do |x|
      break false if link.include?(x)
    end
  end


  def ==(another_page)
    self.uri.to_s == another_page.uri.to_s
  end

  def self.get_page_and_inputs(url)
    mechanize = Mechanize.new
    page = mechanize.get url
    page = Nokogiri::HTML(page.body, "UTF-8")
    page.css('input').size
  end
end