class Gene < Database
  #Instances of this class have an only accessible property: gene_data.
  #@database is also stored within this instances, but only to make
  #some name conversions.
  attr_accessor :gene_data
  
  ##############
  # initialize #
  ##############
  
  #I chose to initialize instances of this class by entering an existing array.
    
    def initialize(array = Array.new)
      @gene_data = Hash.new   # By default, @gene_data is an empty hash
      
      if Regexp.new(/A[Tt]\d[Gg]\d{5}/).match(array[0])
        @gene_data[array[0].to_sym] = {Gene_name: array[1], mutant_phenotype: array[2]}
      elsif array[0]
        puts "Wrong AGI code (#{array[0]}): entry has been excluded."
      end
    end
    
  ##################
  # gene_from_file #
  ##################
    
  #Because Database.load_from_file method evaluates if values in second column
  #are AGI codes, I cannot reuse the code to load gene_data (AGI codes here are
  #found in the first column). So, I have defined a new tsv-reading method.
    
    def gene_from_file(tsv_file)
      @gene_data = File.open(tsv_file, "r") {|file|
        database = Hash.new()  
        f = file.read.split("\n")  
        
        headers = f[0].split("\t")  
        headers = headers[1...headers.length()]
        f[1...f.length()].each {|line| 
          cells = line.split("\t")      
          agi_code = cells[0]
          unless Regexp.new(/A[Tt]\d[Gg]\d{5}/).match(agi_code)
            puts "Gene excluded because of wrong AGI: #{agi_code}"
            next
          end
          
          database[agi_code.to_sym] = Hash.new()
          cells = cells[1...cells.length()]
          i = -1
          cells.each {|cell|
            i += 1
            database[agi_code.to_sym][headers[i].to_sym] = cell
            }  
        }
        database
      }
    end
    
    ###############
    # agi_to_name #
    ###############
    
    #Takes an only parameter (AGI locus code) and returns the gene name
    #associated to this AGI locus code. Both are present in gene_data
    #database.
    
    def agi_to_name(agi_code)
      return @gene_data[agi_code.to_sym][:Gene_name]
    end
    
    ################
    # agi_to_stock #
    ################
    
    #Similar to the method above, it takes an only AGI locus code. In this
    #case, this method returns the stock seed ID associated with AGI locus
    #code entered
    
    def agi_to_stock(agi_code)
        @database.each {|id, value|
            if value[:Mutant_Gene_ID] == agi_code
                return id
            end}
    end
    
    #################
    # stock_to_name #
    #################
    
    #This method links @database and @gene_data databases. It returns the gene
    #name associated to the stock ID entered
    
    def stock_to_name(seed_stock)
      agi = @database[seed_stock.to_sym][:Mutant_Gene_ID]
      return @gene_data[agi.to_sym][:Gene_name]
    end
end