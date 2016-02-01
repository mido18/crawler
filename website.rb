require_relative 'page'
require 'work_queue'
# require 'pry'
class Website

  attr_accessor :pages , :max_number_of_pages, :max_depth

  def initialize(url,max_number_of_pages,max_depth)
    @pages = []
    @pages << Page.new(url).get_metadata
    @max_number_of_pages = max_number_of_pages.to_i
    @max_depth = max_depth.to_i
  end

  def crawl
    wq = WorkQueue.new 5
    semaphore = Mutex.new
    @pages.each do |page|
      page.links.each do |link|
        wq.enqueue_b do
          p = Page.new(link)
          unless @pages.include? p
            begin
              p.get_metadata
              semaphore.synchronize do
                @pages << p if @pages.size != max_number_of_pages
              end
            rescue Mechanize::ResponseCodeError
              semaphore.synchronize do
                page.links.delete(link)
              end
            end
          end
        end
      end
      wq.join
    end
  end

  def find_page(url)
    @pages.select{|page| page.uri.to_s == url}.first
  end


end