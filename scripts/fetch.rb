require 'nokogiri'
require 'open-uri'

File.open('/tmp/links.txt', 'w') do |f|
  contributors = Nokogiri::HTML(open('http://archive.org/browse.php?collection=prelinger&field=creator'))
  contributors.css('ul li a').each do |link|
    puts "[#{link.content}] ..."
    relative = "http://archive.org#{link['href']}"
    created = Nokogiri::HTML(open(relative))
  
    created.css("td a.titleLink").each do |hit|
      puts "[#{link.content}] [#{hit.content}] ..."
      movie_page = "http://archive.org#{hit['href']}"
      movie = Nokogiri::HTML(open(movie_page))
      movie.css('div.box a').each do |bit| 
        if bit['href'] =~ /\.ogv/
          puts "found Ogg at http://archive.org#{bit['href']}"
          f.puts "http://archive.org#{bit['href']}"
        end
      end
    end
  end
end 
