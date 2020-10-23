require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin

    legislators = civic_info.representative_info_by_address(
                            address: zip,
                            levels: 'country',
                            roles: ['legislatorUpperBody', 'legislatorLowerBody']).officials
    #legislators = legislators.officials
    
    #legislator_names = legislators.map(&:name)

     #legislator_names.join(", ")
  
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end

end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, "w") do |file|
    file.puts form_letter
  end
end

def phone_cleanup(phone_number)
  numbers = "0123456789"

  cleaned_number = ""

  phone_number.each_char do |char|
    if numbers.include?(char)
      cleaned_number << char
    end
  end

  if cleaned_number.length < 10
    "bad number"
  elsif cleaned_number.length > 11
    "bad number"
  elsif cleaned_number.length == 11 && cleaned_number[0] == "1"
    cleaned_number.insert(4, "-") 
    cleaned_number.insert(8, "-")
    return cleaned_number[1..-1]
  
  else cleaned_number.insert(3, "-") 
    cleaned_number.insert(7, "-")
    return cleaned_number
  #If the phone number is less than 10 digits assume that it is a bad number
  #If the phone number is 10 digits assume that it is good
  #If the phone number is 11 digits and the first number is 1, trim the 1 and use the first 10 digits
  #If the phone number is 11 digits and the first number is not 1, then it is a bad number
  #If the phone number is more than 11 digits assume that it is a bad number
  end

end

puts "EventManager Initialized!"

contents = File.open("/home/michael/odin_project/event_manager/event_attendees.csv")
template_letter = File.open("/home/michael/odin_project/event_manager/form_letter.erb").read
erb_template = ERB.new template_letter

lines = CSV.open(contents, headers: true, header_converters: :symbol)
lines.each do |row|
  id = row[0]
  name = row[:first_name]
  phone = row[:homephone]
  reg_date = row[:regdate]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  #personal_letter = template_letter.gsub('FIRST_NAME',name)
  #personal_letter.gsub!('LEGISLATORS',legislators)
  form_letter = erb_template.result(binding)

  #save_thank_you_letter(id, form_letter)
  
  puts reg_date
  
  
  #puts personal_letter
  #puts "#{name} #{zipcode} #{legislators}"
 end
  
  

 