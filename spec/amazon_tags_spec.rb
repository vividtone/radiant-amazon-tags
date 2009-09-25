require File.dirname(__FILE__) + '/spec_helper'

describe 'AmazonTags' do
  dataset :pages

  describe '<r:amazon>' do
    it "should find an item by ASIN" do
      tag = '<r:amazon asin="4798021377"><r:item_title /></r:amazon>'
      expected = '入門Redmine Linux/Windows対応'
      pages(:home).should render(tag).as(expected)
    end
  end

  describe '<r:amazon:each>' do
    it "should find an item by ASIN" do
      tag = '<r:amazon:each asin="4798021377"><r:item_title /></r:amazon:each>'
      expected = '入門Redmine Linux/Windows対応'
      pages(:home).should render(tag).as(expected)
    end

    it "should blank when no item found" do
      tag = '<r:amazon:each asin="asin_which_never_exists"><r:item_title /></r:amazon:each>'
      expected = ''
      pages(:home).should render(tag).as(expected)
    end

    it "should iterate found items." do
      tag = '<r:amazon:each keywords="sho-co-songs collection" search_index="Music"><r:count /></r:amazon:each>'
      pages(:home).should render(tag).as("333")
    end
  end

  describe '<r:amazon:item_title>' do
    it "should render the item's title" do
      tag = '<r:amazon:first asin="4798021377"><r:item_title /></r:amazon:first>'
      expected = '入門Redmine Linux/Windows対応'
      pages(:home).should render(tag).as(expected)
    end
  end

  describe '<r:amazon:count>' do
    it "should render the found items count" do
      tag = '<r:amazon:each asin="4798021377"><r:count /></r:amazon:each>'
      expected = '1'
      pages(:home).should render(tag).as(expected)
    end
  end

  describe '<r:amazon:detail_page_url>' do
    it "should render the detail_page_url" do
      tag = '<r:amazon:first keywords="perfume game" search_index="Music"><r:detail_page_url /></r:amazon:first>'
      expected = %r(http://www.amazon.co.jp/.*/B00132S3SK)
      pages(:home).should render(tag).matching(expected)
    end
  end

  describe '<r:amazon:lowest_new_price>' do
    it "should render the lowest_new_prise" do
      tag = '<r:amazon:first keywords="perfume game" search_index="Music"><r:lowest_new_price /></r:amazon:first>'
      expected = /￥[0-9,\s]+/
      pages(:home).should render(tag).matching(expected)
    end
  end

  describe '<r:amazon:lowest_used_price>' do
    it "should render the lowest_used_prise" do
      tag = '<r:amazon:first keywords="perfume game" search_index="Music"><r:lowest_used_price /></r:amazon:first>'
      expected = /￥[0-9,\s]+/
      pages(:home).should render(tag).matching(expected)
    end
  end

  describe '<r:amazon:image_url>' do
    it "should render medium image url" do
      tag = '<r:amazon:first keywords="perfume game" search_index="Music"><r:image_url /></r:amazon:first>'
      expected = 'http://ecx.images-amazon.com/images/I/41fzTIPGGvL._SL160_.jpg'
      pages(:home).should render(tag).as(expected)
    end

    it "should render small image url" do
      tag = '<r:amazon:first keywords="perfume game" search_index="Music"><r:image_url size="small"/></r:amazon:first>'
      expected = 'http://ecx.images-amazon.com/images/I/41fzTIPGGvL._SL75_.jpg'
      pages(:home).should render(tag).as(expected)
    end

    it "should render large image url" do
      tag = '<r:amazon:first keywords="perfume game" search_index="Music"><r:image_url size="large"/></r:amazon:first>'
      expected = 'http://ecx.images-amazon.com/images/I/41fzTIPGGvL.jpg'
      pages(:home).should render(tag).as(expected)
    end
  end

  describe '<r:amazon:image>' do 
    it "should render a image with a link" do
      tag = '<r:amazon:first asin="4798021377"><r:image /></r:amazon:first>'
      expected = %r(<a href="http://www.amazon.co.jp.*4798021377.*"><img src="http://ecx.images-amazon.com/images/I/41vBIvHrjfL._SL160_.jpg" /></a>)
      pages(:home).should render(tag).matching(expected)
    end

    it "should have extra attributes in image tag" do
      tag = '<r:amazon:first asin="4798021377"><r:image align="right" /></r:amazon:first>'
      expected = %r(<a href="http://www.amazon.co.jp.*4798021377.*"><img src="http://ecx.images-amazon.com/images/I/41vBIvHrjfL._SL160_.jpg" align="right" /></a>)
      pages(:home).should render(tag).matching(expected)
    end
  end

  describe '<r:amazon:item_link>' do
    it "should render a title with a link" do
      tag = '<r:amazon:first asin="4798021377"><r:item_link /></r:amazon:first>'
      expected = %r(<a href="http://www.amazon.co.jp.*4798021377.*">入門Redmine Linux/Windows対応</a>)
      pages(:home).should render(tag).matching(expected)
    end
  end

  describe '<r:amazon:artist>' do
    it "should render the artist's name of the title." do
      tag = '<r:amazon asin="B001C18KDA"><r:artist /></r:amazon>'
      expected = '鈴木祥子'
      pages(:home).should render(tag).as(expected)
    end
  end

end
