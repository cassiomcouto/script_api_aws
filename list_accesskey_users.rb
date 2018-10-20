require 'aws-sdk'

iam = Aws::IAM::Client.new(region: 'us-east-1')

# Lista todas access keys de cada usuario
def list_keys(iam, user_name)
  begin 
    user = iam.list_access_keys({ user_name: user_name })

    if user.access_key_metadata.count == 0
      puts "No access keys."
    else
      user.access_key_metadata.each do |key_metadata|
       @key = key_metadata.access_key_id
      end
    end
  
  rescue Aws::IAM::Errors::NoSuchEntity
    puts "Cannot find user '#{user_name}'."
    exit(false)
  end 
end

iam.list_users.users.each do |u|
  puts "------------"
  puts "User: #{u.user_name}"
    list_keys(iam,u.user_name)
  puts "Access keys:  #{@key}"
end