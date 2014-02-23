begin
  " ".squish
rescue
  class String

    def squish
      dup.squish!
    end

    def squish!
      gsub!(/\A[[:space:]]+/, '')
      gsub!(/[[:space:]]+\z/, '')
      gsub!(/[[:space:]]+/, ' ')
      self
    end
    
  end
end