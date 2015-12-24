# encoding: UTF-8
require 'nokogiri' 
require 'json'
require 'open-uri'
require 'pp'
require 'mysql2'

host ="https://www.ptt.cc"
doc = String
data, link, post_id, articles_of_page= []
doc_article, title, ptt_link, ptt_id = String
json_file = "./ptt.json"
count = Integer
contents = String
#  regex =gsub("'", '\\').gsub("：",'\\').gsub(";",'\\').gsub("$",'\\').gsub(",",'\\').gsub("，",'\\').gsub    ("！",'\\').gsub("～",'\\').gsub("~",'\\').gsub("/\s",' ') 
#  ptt_tag=%w(看板,標題,作者)

def parse_content(url)
client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "", :database => "demo_development")
    begin
        host ="https://www.ptt.cc" 
        count = 0
        doc = Nokogiri::HTML(open(url))	#HTML開啟
        data = doc.css('.r-ent').css('.title').css('/a[@href]').to_a #將頁面上的文章資訊轉成陣列
        articles_of_page = []
        data.each do |link|
            link = data[count]['href']	#取陣列中"href"欄位
            post_id = link.split("/")[3]
            ptt_link = host+link
            ptt_id = link.match /[M].\d{10}\.[A-Z].\w{3}/
            puts ptt_id
            doc_article= Nokogiri::HTML(open(ptt_link))rescue OpenURI::HTTPError 
            next if doc_article.nil?
            content_text = doc_article.to_s
#              contents = content_text[/<div id="main-content" class="bbs-screen bbs-content">(.+?)※ 發信站/m, 1].to_s
            type = content_text[/\看板\<\/span><span class=\"article-meta-value\">(.*?)<\/span>/m, 1]
            author = content_text[/<span class=\"article-meta-value\">(.+?)<\/span>/m, 1]
            # 作者
            title = content_text[/<span class=\"article-meta-tag\">標題<\/span><span class=\"article-meta-value\">(.*?)<\/span>/m, 1].to_json.gsub("'",'\\')
            #標題
            contents = content_text[/\w{3}\s\w{3}\s\d{2}\s\d{2}:\d{2}:\d{2}\s\d{4}(.+?)※ 發信站/m, 1].to_json.gsub("'",'\\')
			#內文
            count +=1
            result = client.query("INSERT INTO posts (ptt_post_id, ptt_post_link, name, content) VALUES ('#{ptt_id}', '#{ptt_link}', '#{title}', '#{contents}')")          
			 sleep 0.1
        end
        rescue Errno::ECONNRESET =>e
            puts e
                sleep 1
                retry
        end
end

first_page = host + "/bbs/Beauty/index.html"
index_doc = Nokogiri::HTML(open(first_page))
html = index_doc.css("//div[@class='btn-group pull-right']").css('/a[@class]').to_a
next_page = html[2]['href']#下頁
if next_page == nil
    url = host+ "/bbs/Beauty/index.html"
    puts url
    parse_content(url)
end
page_number = html[1]['href'].split("/")[3][5..8].to_i
page_number.times do |link_number|
page_number -=1
url = host+ "/bbs/Beauty/index#{page_number}.html"
puts url 
first_page = url
parse_content(url)
#  sleep 0.1
break if page_number == 0
end
