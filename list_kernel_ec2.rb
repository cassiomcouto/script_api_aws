require 'aws-sdk'
require 'net/ssh'

#Declarar usuario ssh
@username = "cassiocouto"

verify_itype=['c5.', 'c5d.', 'i3', 'm5', 'm5d', 'r5', 'r5d', 't3']

ec2 = Aws::EC2::Resource.new(region: 'us-east-1')
cont_instancia=0
cont_notaccess=0
#Lista todas as instancias
ec2.instances.each do |i|
 if verify_itype.include? i.instance_type.split(".").first
  begin
   puts "------------"

   i.tags.each do |tag|
    if tag.key == "Name"
     @name = tag.value
      end
   end
   
   puts "Name: #{@name}"
   puts "Type: #{i.instance_type}"
   cont_instancia = cont_instancia + 1
   
   #Acessa a maquina por ssh
   Net::SSH.start("#{i.private_ip_address}", "#{@username}") do |ssh|
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
 puts "Total de instancia do typo informado: #{cont_instancia}"
 puts "Total de instancia erro: #{cont_notaccess}"