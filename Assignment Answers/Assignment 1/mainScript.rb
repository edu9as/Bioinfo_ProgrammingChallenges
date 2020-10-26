require "./DatabaseObject.rb" 
require "./GeneObject.rb"
require "./CrossObject.rb"

# 1. Database is generated making use of Database class
puts; puts "- Reading #{ARGV[1]} file and storing seed stock values..."
db = Database.new()
db.load_from_file(ARGV[1])

# 2. Seven grams of each stock are planted, and the updated database is
#    stored in a file
puts; puts "- Planting 7 grams of seeds from each of the records..."
db.planting_seeds(7)
puts; puts "- Writing #{ARGV[3]} file with the updated seed stocks..."
db.write_file(ARGV[3])

# 3. Gene database is loaded from tsv file. Also, @database is loaded within
#    gene variable
puts; puts "- Reading #{ARGV[0]} file and storing gene values..."
gene = Gene.new()
gene.gene_from_file(ARGV[0])
gene.load_from_file(ARGV[1])

# 4. Chi-square test
puts; puts "- Reading #{ARGV[2]} file and storing cross values..."
cross = File.open(ARGV[2], "r") {|file|               #  and the headers will be the keys
        f = file.read.split("\n")
        cross_data = []
        i=-1
        f[1...f.length()].each {|line|
          i += 1
          cells = line.split("\t")      # Separate values by tab
          cross_data[i] = {}
          cross_data[i]["Parent1".to_sym] = cells[0]
          cross_data[i]["Parent2".to_sym] = cells[1]
          cross_data[i]["Observed".to_sym] = cells[2...cells.length()]
          for j in 0...cells.length()-2
            cross_data[i]["Observed".to_sym][j] = cross_data[i]["Observed".to_sym][j].to_i
          end
        }
        cross_data}

puts; puts "- Processing hybrid cross information..."
cross.each {|dict|
  inst = HybridCross.new(dict)
  
  if inst.chi_sq() > 7.81   # For 3 degrees of freedom, 0.05-probability threshold is 7.81
    gene1 = gene.stock_to_name(dict[:Parent1])
    gene2 = gene.stock_to_name(dict[:Parent2])
    puts "#{gene1} is genetically linked to #{gene2} with chi-square #{inst.chi_sq}"
  end
}

# 5- Bonus scores
puts; puts

puts "################"; puts "# BONUS SCORES #"; puts "################"
puts
puts "###################"; puts "# DEMONSTRATION 1 #"; puts "###################"
puts
puts "1- My Gene object tests the format of the Gene Identifier and rejects"
puts "   incorrect formats without crashing. Try entering a row by yourself."
test1 = "y"
while test1 == "y"
  puts; print "   Enter AGI code of the gene:$ "
  agi = STDIN.gets.chomp
  print "   Enter gene name:$ "
  name = STDIN.gets.chomp
  print "   Enter a brief mutant phenotype description:$ "
  mutant = STDIN.gets.chomp
  
  puts
  puts "   (If AGI code is correct, a new entry is stored. If AGI code"
  puts "    is wrong, the entry is excluded and a message is displayed.)"
  puts;puts "   As a result:"
  test_gene = Gene.new([agi, name, mutant])
  if test_gene.gene_data != {}
    puts test_gene.gene_data
  end
  
  
  
  puts
  puts "Do you want to repeat this test with another AGI code?"
  puts "   - Enter y to repeat."
  puts "   - Enter anything else to escape."
  test1 = STDIN.gets.chomp
end
puts;puts
puts "###################"; puts "# DEMONSTRATION 2 #"; puts "###################"
puts
puts "2- My seed-stock object represents the entire database. All entries in the"
puts "   tsv file have been read correctly using load_from_file method."
puts; db.database.each {|k, v| puts "{:#{k}=> #{v}}"}
puts
puts "   Also, the object accesses individual objects based on their ID and has "
puts "   a write_database method that writes a tsv file with the updated database."
test2 = "y"
while test2 == "y"
  print "   Enter seed stock ID: "
  stock = STDIN.gets.chomp
  puts; puts "   This is the information about #{stock} ID stored in the database:"
  puts
  puts db.get_seed_stock(stock)
  
  puts
  puts "   And below you can see the tsv file generated with the updated database."
  puts
  system("cat #{ARGV[3]}")
  
  puts; puts "Do you want to repeat this test with another AGI code?"
  puts "   - Enter y to repeat."
  puts "   - Enter anything else to escape."
  test2 = STDIN.gets.chomp
end