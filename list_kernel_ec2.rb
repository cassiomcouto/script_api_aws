require 'aws-sdk'
require 'net/ssh'

#Declarar usuario ssh
@username = "cassiocouto"

verify_itype=['c5', 'c5d', 'i3', 'm5', 'm5d', 'r5', 'r5d', 't3']

ec2 = Aws::EC2::Resource.new(region: 'us-east-1')
cont_instance=0
cont_notaccess=0
#Lista todas as instancias
ec2.instances.each do |instance|
 if verify_itype.include? instance.instance_type.split(".").first
  begin
   puts "------------"

   instance.tags.each do |tag|
    if tag.key == "Name"
     @name = tag.value
      end
   end
   
   puts "Name: #{@name}"
   puts "Type: #{instance.instance_type}"
   cont_instance = cont_instance + 1
   
   #Acessa a maquina por ssh
   Net::SSH.start("#{instance.private_ip_address}", "#{@username}") do |ssh|
     @kernel = ssh.exec!("uname -r")
   end
  
   puts "Kernel: #{@kernel}"

  #Caso não consiga acessa a maquina retorna o erro  
  rescue Exception => e
   puts "Erro:"+e.message
   cont_notaccess = cont_notaccess + 1
      next
  end 
 end
end 
 puts "-------------------------------------------------------" 
 puts "Total de instancias: #{cont_instance}"
 puts "Total de instancias com erro de acesso: #{cont_notaccess}"
