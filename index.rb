require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'csv'

PAGE_URL = "http://www.bbb.org/new-jersey/accredited-business-directory/painting-contractors/299/"

index_page = Nokogiri::HTML(open(PAGE_URL))

links = Array.new

index_page.css("div.nme a").each do |link|
  links << link["href"]
end


companies_name = Array.new
phone_numbers = Array.new
street_address = Array.new
email = Array.new
website = Array.new
zip = Array.new
owner_name = Array.new
description = Array.new
founded = Array.new
rating = Array.new

# TEST CODE
# links.each do |link|
# 	contractor_page = Nokogiri::HTML(open(link))
# 	h5_tags = contractor_page.css("div#business-additional-info-text h5")
# 	index_of_business_management = nil
# 	h5_tags.each_with_index do |text, idx|
# 		if text.text == "Business Management"
# 			index_of_business_management = idx
# 		end
# 	end
# 	owner = contractor_page.css("div#business-additional-info-text h5")[index_of_business_management].next_element.text.strip
# 	puts owner
# end

links.each do |link|
	contractor_page = Nokogiri::HTML(open(link))

	company_name = contractor_page.css("h1.business-title").text.strip
	companies_name << company_name
	puts company_name

	# TODO: Strip prefix "Phone: "
	phone = contractor_page.css("span.business-phone").text.strip
	phone_numbers << phone
	puts phone

	#TODO: Address & zip

	# Can not scrape email due to obfuscateText
	# email_address = contractor_page.css("span.business-email a").text.strip
	# email << email_address
	# puts email_address

	website_url = contractor_page.css("span.business-link").text.strip
	website << website_url
	puts website_url


	h5_tags = contractor_page.css("div#business-additional-info-text h5")
	index_of_business_management = nil
	h5_tags.each_with_index do |text, idx|
		if text.text == "Business Management"
			index_of_business_management = idx
		end
	end
	if index_of_business_management == nil
		owner = ""
	else
		owner = contractor_page.css("div#business-additional-info-text h5")[index_of_business_management].next_element.text.strip
		owner_name << owner
	end
	puts owner
end



# (0..(companies_name.length - 1)).each do |num|
# 	puts companies_name[num]
# 	puts phone_numbers[num]
# 	puts "================="
# end	

CSV.open("painting_contractors_nj.csv", "wb") do |row|
  row << ["Companies Name", "Phone Numbers", "Website", "Owner"]
  (0..companies_name.length - 1).each do |index|
    row << [companies_name[index], phone_numbers[index], website[index], owner_name[index]]
  end
end

