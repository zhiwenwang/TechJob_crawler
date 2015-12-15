require 'nokogiri' 
require 'json'
require 'open-uri'
host ="https://www.ptt.cc"
doc = String
data, link, post_id, articles_of_page= []
doc_article, title, content_text = String
#  next_page = html[2]['href']#下頁
#  previous_page = html[1]['href']#上頁
count = Integer

def parse_content(url)
    begin
        host ="https://www.ptt.cc" 
        count = 0
        doc = Nokogiri::HTML(open(url))	#HTML開啟
        data = doc.css('.r-ent').css('.title').css('/a[@href]').to_a #將頁面上的文章資訊轉成陣列
        articles_of_page = []
        data.each do |link|
            link = data[count]['href']	#取陣列中"href"欄位
            post_id = link.split("/")[3]
            title = data[count].text	
            doc_article= Nokogiri::HTML(open(host+link))
            content_text = doc_article.xpath("//div[@class='bbs-screen bbs-content']").text
            count = count +1
            articles_of_page.push({:post_id=>post_id, :link_url=>link, :title=>title, :content=>content_text})
        end
        puts "GET____ARTICLES:#{articles_of_page.length}"
        articles_of_page.each do |a|
            puts "TITLE____:#{a[:title]}"
        end
    rescue 
        puts "FQ   REREY"
        sleep 5.3
        parse_content(url)
    end
end

first_page = host + "/bbs/Tech_Job/index.html"
index_doc = Nokogiri::HTML(open(first_page))
html = index_doc.css("//div[@class='btn-group pull-right']").css('/a[@class]').to_a
page_number = html[1]['href'].split("/")[3][5..8].to_i
page_number.times do |link_number|
link_number = html[1]['href'].split("/")[3][5..8].to_i
puts page_number 
page_number -=1
url = host+ "/bbs/Tech_Job/index#{page_number}.html"
first_page = url
parse_content(url)
parse_content(first_page)
end


#  pg_idx = 2018
#  20.times do |gg|
#      pg_idx-=1
#      puts "IDX:#{pg_idx}"
#      url = host+"/bbs/Tech_Job/index#{pg_idx.to_s}.html"
#      parse_content(url)

#              if html[1]['href'] == nil
#                  url = index_url
#                  url=host#{next_page}
#                  parse_content(url)
#              end
#  end
