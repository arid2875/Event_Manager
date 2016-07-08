require "csv"
require "sunlight/congress"
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)  
end

def clean_phone(phone_number)
	phone_number = phone_number.tr(".,\\-() ", '')
  bad_phone = '0000000000'
  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11
    if phone_number[0] == '1'
      phone_number[1..10]
    else
      bad_phone
    end
  else
    bad_phone
  end
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def collect_times
end

puts "EventManager initialized"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
hours = Hash.new
(0..23).each {|hour| hours[hour] = 0}
days = Hash.new 0




contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone(row[:phone])       
  registration_time = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M")
  hours[registration_time.hour] += 1
  days[registration_time.wday] += 1
  legislators = legislators_by_zipcode(zipcode) 

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)
end

days.each do |key, value|
  if value > 0
    puts "#{key}: #{value}"
  end
end

puts ""

hours.each do |key, value|
  if value > 0
    puts "#{key}: #{value}"
  end
end

