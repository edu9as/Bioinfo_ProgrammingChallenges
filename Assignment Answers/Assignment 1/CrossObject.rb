class HybridCross
  # Instances of this class have three properties: each of the parents in the
  # cross and the observed individuals for each phenotype. Each parent is a
  # string, while observed phenotypes is an array. 
  attr_accessor :parent1
  attr_accessor :parent2
  attr_accessor :observed
    def initialize(params = {})
      @parent1 = params.fetch(:Parent1, "")
      @parent2 = params.fetch(:Parent2, "")
      @observed = params.fetch(:Observed, [])
    end
    
    ############
    # expected #
    ############
    
    # This method calculates the expected individuals for each phenotype in F2.
    # The default segregation is 9:3:3:1, and with this proportion an array is
    # generated with the expected individuals for this segregation given a total
    # number of individuals. The output is another array.
    
    def expected(segregation = [9,3,3,1])
      @total = @observed.sum.to_f
      expected = []
      for i in 0...segregation.length()
        expected.push(@total*segregation[i]/segregation.sum)
      end
      return expected
    end
    
    ##########
    # chi_sq #
    ##########
    
    # This method computes the chi-square test for each cross observed offspring.
    # A number is returned. Outside of this function, it will be tested if this
    # chi-square is significative or not depending on the liberty degrees.
    
    def chi_sq(observed = @observed, expected = expected())
      diff_sq = []
      for i in 0...@observed.length()
        diff_sq.push((@observed[i]-expected[i])**2/expected[i])
      end
      return diff_sq.sum
    end
    
end