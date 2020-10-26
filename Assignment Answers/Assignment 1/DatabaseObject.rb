class Database
    # Instances of this class have an only property: a database (@database),
    #    which is an array of arrays. The key for the outter array is the
    #    seed stock ID, while the keys of the inner array are the names of
    #    the other columns in the initial tsv. This way, all records can be
    #    accessed first by ID and then by column name.
    #
    # Also, this class contains some methods: load_from_file, planting_seeds,
    #    get_seed_stock and write_file. They will be documented right above
    #    their definition.
    
    attr_accessor :database
    
    ##############
    # initialize #
    ##############
    
    # I chose a very simple initialization method, just in case I wanted to
    # reutilize this class and I already had an hash filled as described
    # above. By default, @database is an empty hash, which will be updated with
    # next methods.
    
    def initialize(hash = Hash.new())
      @database = hash
    end
    
    ##################
    # load_from_file #
    ##################    
    
        #- load_from_file reads a tsv_file, whose first column is expected to
        #  be the seed-stock ID. As a result of this method, the @database
        #  variable is updated with the information contained by tsv. This
        #  method also excludes tsv-rows for which AGI code does not match
        #  the structure of Arabidopsis'  
    
    def load_from_file(tsv_file)
      @database = File.open(tsv_file, "r") {|file|
        database = Hash.new()  
        f = file.read.split("\n")  # Split tsv in rows
        
        headers = f[0].split("\t")   # Split first row (headers) by tab
        headers = headers[1...headers.length()]
        f[1...f.length()].each {|line| 
          cells = line.split("\t")     # Split each row by tab
          entry = cells[0]   # Stock seed ID, key for the outter hash
          
          unless Regexp.new(/A[Tt]\d[Gg]\d{5}/).match(cells[1]) # Check AGI code
            puts "Seed stock excluded because of wrong AGI: #{cells[1]}"
            next   # If AGI code doesn't match that of Arabidopsis, that row is
                   # not added to the @database hash.
          end
          
          database[entry.to_sym] = Hash.new()  # Each stock ID is associated to
                                               #   a new hash
          cells = cells[1...cells.length()]    # Stock ID excluded from values
                                               #   of new hash
          headers.each {|head| database[entry.to_sym][head.to_sym] = []}
          i = -1
          cells.each {|cell|
            i += 1
            if headers[i].to_sym == :Grams_Remaining
              database[entry.to_sym][headers[i].to_sym] = cell.to_i
            else
              database[entry.to_sym][headers[i].to_sym] = cell
            end 
            }}
        database  # @database will be equal to the last call within the block
      }
    end
    
    ##################
    # planting_seeds #
    ##################
    
    #This method, whose only parameter is the amount of grams to be planted,
    #overwrites the initial database. If stock grams reach 0, a warning message
    #is displayed. If stock grams are lower than amount to be planted, only the
    #remaining stock grams are planted and a warning message is displayed.
    
    def planting_seeds(amount = 0)
      @database.each {|k, v|
        if v[:Grams_Remaining] == amount
          puts "WARNING: we have run out of Seed Stock #{k}"
          v[:Grams_Remaining] = 0
        elsif amount > v[:Grams_Remaining]
          planted = v[:Grams_Remaining]
          puts "WARNING: only #{planted} grams have been planted, because we have run out of Seed Stock #{k}"
          v[:Grams_Remaining] = 0
        else
          v[:Grams_Remaining] -= amount
        end
        }
      print 
    end
    
    ##################
    # get_seed_stock #
    ##################
    
    # This simple method takes an only parameter: a seed_stock ID. If this ID
    # is present in the @database hash as a key, the information associated to
    # this ID is returned. If not, a warning message is displayed.
    
    def get_seed_stock(seed_stock)
      if database[seed_stock.to_sym]
        return @database[seed_stock.to_sym]
      else
        puts "No stock for this seed stock ID."
      end
    end
    
    ##############
    # write_file #
    ##############
    
    # This method takes an only parameter: the name of the file to be written.
    # It reads the whole @database, one by one, and appends to an string every- 
    # thing in an appropriate manner:
    #   - In the first line of the string, headers are tab-separated. Remember
    #       where the keys of all inner hashes.
    #   - In the following lines, each stock ID is appended to the string,
    #       along with all inner values associated to it (tab-separated)
    #
    # After calling this method, a new file named by user is generated.
    
    def write_file(name)
      str = "Seed_Stock\t"
      @database.values()[0].keys().each {|k|
        str += k.to_s + "\t"}
      str += "\n"

      @database.each {|k1, v1|
        str += k1.to_s + "\t"
        v1.each {|k2, v2|
          str +=  v2.to_s + "\t"}
        str += "\n"
        }
      File.open(name, "w") { |f| f.write str }     
    end
    
end

