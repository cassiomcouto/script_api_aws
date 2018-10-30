require "aws-sdk"
require "net/ssh"

verify_itype = ["c5", "c5d", "i3", "m5", "m5d", "r5", "r5d", "t3"]

ec2 = Aws::EC2::Resource.new(region: "us-east-1")
cont_instance = 0
cont_NotAccess = 0
@versionOS = "4.4.0"
@subversion14 = "1029"
@subversion16 = "1067"
#Lista todas as instancias
ec2.instances.each do |instance|
  if verify_itype.include? instance.instance_type.split(".").first
    begin
      instance.tags.each do |tag|
        if tag.key == "Name"
          @name = tag.value
        end
      end
      cont_instance = cont_instance + 1
      @print = "#{@name} |#{instance.instance_type} |#{instance.private_ip_address}"

      #Acessa a maquina por ssh
      Net::SSH.start("#{instance.private_ip_address}") do |ssh|
        @kernel = ssh.exec!("uname -r").gsub(/\n\z/, "").split("-")
        @SO = ssh.exec!("cat /etc/issue.net").gsub(/\n\z/, "")
      end

      if "Ubuntu 16" == @SO.split(".").first
        if @versionOS.eql? @kernel.first
          if @subversion16 <= @kernel[1]
            @versionStatus = "OK"
          else
            @versionStatus = "DEPRECED"
          end
        else
          @versionStatus = "DEPRECED"
        end
      end

      if "Ubuntu 14" == @SO.split(".").first
        if @versionOS.eql? @kernel.first
          if @subversion14 <= @kernel[1]
            @versionStatus = "OK"
          else
            @versionStatus = "DEPRECED"
          end
        else
          @versionStatus = "DEPRECED"
        end
      end

      puts "#{@print} |#{@SO} |#{@kernel[0]}-#{@kernel[1]} | #{@versionStatus} "

      #Caso não consiga acessa a maquina retorna o erro
    rescue Exception => e
      puts "#{@print} | #{e.message}"
      cont_NotAccess = cont_NotAccess + 1
      next
    end
  end
end
puts "-------------------------------------------------------"
puts "Total de instancias: #{cont_instance}"
puts "Total de instancias com erro de acesso: #{cont_NotAccess}"
