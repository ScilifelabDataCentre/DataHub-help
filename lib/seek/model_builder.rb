require 'hpricot'

module Seek
  
  module ModelBuilder
    BUILDER_URL_BASE = "http://jjj.mib.ac.uk/webMathematica/Examples/JWSconstructor_panels"
    SIMULATE_URL = "http://jjj.mib.ac.uk/webMathematica/upload/uploadNEW.jsp"
    
    def self.builder_url
      "#{BUILDER_URL_BASE}/DatFileReader.jsp"
    end
    
    def self.upload_dat_url
      self.builder_url+"?datFilePosted=true"
    end        
    
    def self.simulate_url
      SIMULATE_URL
    end
    
    def self.construct model,params
      
      required_params=["assignmentRules","modelname","parameterset","kinetics","functions","initVal","reaction","events","steadystateanalysis"]
      url = builder_url
      form_data = {}
      required_params.each do |p|
        form_data[p]=params[p] if params.has_key?(p)
      end
      
      response = Net::HTTP.post_form(URI.parse(url),form_data)
      
      if response.instance_of?(Net::HTTPInternalServerError)       
        puts response.to_s
        raise Exception.new(response.body.gsub(/<head\>.*<\/head>/,""))
      end
      
      process_response_body(response.body)
    end
    
    def self.get_builder_content model
      filepath=model.content_blob.filepath
      
      part=Multipart.new({:uploadedDatFile=>filepath})
      
      response = part.post(upload_dat_url)
      
      if response.instance_of?(Net::HTTPInternalServerError)       
        puts response.to_s
        raise Exception.new(response.body.gsub(/<head\>.*<\/head>/,""))
      end
      
      process_response_body(response.body)
      
    end
    
    def self.simulate saved_file
      url=simulate_url
      url=url+"?savedfile=#{saved_file}&inputFileConstructor=true"           
      
      part=Multipart.new({})
      
      response = part.post(url)
      
      if response.instance_of?(Net::HTTPInternalServerError)       
        puts response.to_s
        raise Exception.new(response.body.gsub(/<head\>.*<\/head>/,""))
      end
      
      if response.instance_of?(Net::HTTPRedirection)
        puts "REDIRECTION TO #{response['location']}"
      end
      
      extract_applet(response.body)
    end
    
    def self.extract_applet body
      doc = Hpricot(body)
      puts body
      element = doc.search("//object").first
      element.inner_html
    end        
    
    def self.process_response_body body            
      body=body.gsub("\";","\"")
      
      doc = Hpricot(body)
      
      scripts_and_stylesheets = process_scripts_and_styles(doc).join("\n")
      div_block = find_the_boxes_div(doc).join("\n")
      div_block = div_block.gsub("window.open('/webMathematica","window.open('http://jjj.mib.ac.uk/webMathematica/")
      saved_file = determine_saved_file doc
      
      return scripts_and_stylesheets,div_block,saved_file
    end
    
    def self.determine_saved_file doc
      element = doc.search("//input[@name='savedfile']").first
      return element.attributes['value']
      
    end
    
    def self.process_scripts_and_styles doc
      
      ss = []
      doc.search("//script").each do |script|
        src=script.attributes['src']
        if src
          src=BUILDER_URL_BASE+"/"+src
          script.attributes['src'] = src  
        end        
        ss << script.to_s
        break if ss.size == 6
      end
      doc.search("//link[@rel='stylesheet']")
      doc.search("//link[@rel='stylesheet']").each do |link|
        href=link.attributes['href']
        
        if href
          href=BUILDER_URL_BASE+"/"+href
          link.attributes['href'] = href  
        end        
        ss << link.to_html
      end            
      
      return ss
    end
    
    def self.find_the_boxes_div doc      
      form_elements = doc.search("//form[@name='form']/div")
      form_elements.search("//img").each do |img|
        if img.attributes['src']
          img.attributes['src'] = BUILDER_URL_BASE+"/"+img.attributes['src']
        end
      end      
      
      [form_elements.first.to_html]      
    end
    
  end
  
end