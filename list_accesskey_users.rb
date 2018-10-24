require 'aws-sdk'

iam = Aws::IAM::Client.new(region: 'us-east-1')

# Lista todas access keys de cada usuario
def list_keys(iam, user_name)
  begin 
    user = iam.list_access_keys({ user_name: user_name })
      user.access_key_metadata.each do |key_metadata|
       @key = key_metadata.access_key_id

    end
  
  rescue Aws::IAM::Errors::NoSuchEntity
    puts "Cannot find user '#{user_name}'."
    exit(false)
  end 
end

iam.list_users.users.each do |u|
  list_keys(iam,u.user_name)
  if @key != nil  
    puts "#{u.user_name} |  #{@key}"
  else
     puts "#{u.user_name} |  Não possui Accees Key"
  end
end