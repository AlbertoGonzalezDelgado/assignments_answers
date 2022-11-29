#Checking if the arguments required are specified 
unless ARGV.length == 2
    abort("FATAL ERROR: Files pathways are required. \nHELP MESSAGE: Check README.md for more information.")
end

#Checking if the input file exists

unless File.file?(ARGV[0])
    abort("FATAL ERROR: File #{ARGV[0]} does not exist or the pathway specified is not correct")
end


#Checking if the output file already exists and asking if it should be overwrite
if File.file?(ARGV[1])
    puts "#{ARGV[1]} already exists, indicate if you want to overwrite [Y/N]" 
    stdin = ""
    until stdin == "n" || stdin == "N" || stdin == "y" || stdin == "Y"
        stdin = STDIN.gets.strip
        if stdin == "N" || stdin == "n"
            abort("Run cancelled")
        end
    end
end

