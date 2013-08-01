# Dependencies ==========

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'csv'

# Variables ==========

BUSINESS_TYPE_URL = "painting-contractors" # Types can be found: http://www.bbb.org/new-jersey/accredited-business-guide/bytob

STATE_URL = "new-jersey"

PAGE_URL = "http://www.bbb.org/#{STATE_URL}/accredited-business-directory/#{BUSINESS_TYPE_URL}"

# Populate links to business specific page ==========

index_page = Nokogiri::HTML(open(PAGE_URL))

links = Array.new

index_page.css("div.nme a").each do |link|
  links << link["href"]
end

# Initialize arrays for data collection ==========

@company = Array.new
@accredidation_date = Array.new
@phone = Array.new
@street_address = Array.new
@email = Array.new
@website = Array.new
@zip = Array.new
@owner = Array.new
@description = Array.new
@founded = Array.new
@rating = Array.new

# TEST CODE
# links.each do |link|
# 	business_page = Nokogiri::HTML(open(link))
# 	h5_tags = business_page.css("div#business-additional-info-text h5")
# 	index_of_business_management = nil
# 	h5_tags.each_with_index do |text, idx|
# 		if text.text == "Business Management"
# 			index_of_business_management = idx
# 		end
# 	end
# 	owner = business_page.css("div#business-additional-info-text h5")[index_of_business_management].next_element.text.strip
# 	puts owner
# end

# Spider for business specific page ==========

links.each do |link|

	# Create a Nokogiri object for the business page ==========
	business_page = Nokogiri::HTML(open(link))

	# Find the company title and push it into @company name array
	company = business_page.css("h1.business-title").text.strip
	@company << company
	puts company

	# Find the accredidation date and push it into @accredidation_date array
	accredidation_date = business_page.css("h3.accredited-since span")[1].text.sub(/document.write\('/, '').sub(/'\);/,'').strip
	@accredidation_date << accredidation_date
	puts accredidation_date

	# Find the compnay phone number and push it into @phone number  array
	# TODO: Strip prefix "Phone: "
	phone = business_page.css("span.business-phone").text.strip
	@phone << phone
	puts phone

	#TODO: Address & zip

	# Can not scrape email due to obfuscateText
	# email_address = business_page.css("span.business-email a").text.strip
	# email << email_address
	# puts email_address

	website = business_page.css("span.business-link").text.strip
	@website << website
	puts website

	# Find the compnay title and push it into @company name array
	h5_tags = business_page.css("div#business-additional-info-text h5")
	index_of_business_management = nil
	h5_tags.each_with_index do |text, idx|
		if text.text == "Business Management"
			index_of_business_management = idx
		end
	end
	if index_of_business_management == nil
		owner = ""
	else
		owner = business_page.css("div#business-additional-info-text h5")[index_of_business_management].next_element.text.strip
		@owner << owner
	end
	puts owner
end



# (0..(companies_name.length - 1)).each do |num|
# 	puts companies_name[num]
# 	puts phone_numbers[num]
# 	puts "================="
# end	

CSV.open("#{BUSINESS_TYPE_URL}-#{STATE_URL}.csv", "wb") do |row|
  row << ["Companies Name", "Accredidation Date", "Phone Numbers", "Website", "Owner"]
  (0..@company.length - 1).each do |index|
    row << [@company[index], @accredidation_date[index], @phone[index], @website[index], @owner[index]]
  end
end

