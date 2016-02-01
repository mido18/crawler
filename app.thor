require 'thor'
require_relative 'website'

require 'benchmark'
class App < Thor

  desc "crawl [url,number_of_page, depth]", "crawl a website"

  def crawl(url, number_of_page = 50,depth =3)
    website = Website.new(url,number_of_page, depth)
    website.crawl
    website.pages.each do |page|
      inputs = page.inputs
      page.links.each do |link|
        linked_page =  website.find_page(link)
        inputs += linked_page.inputs unless linked_page.nil?
        inputs += Page.get_page_and_inputs(link) if linked_page.nil?
      end
      puts "#{page.uri.to_s} - #{inputs}"
    end
    puts "Website pages = #{website.pages.size}"
  end
end