require 'json'

def randstring length
  chars =  [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten

  return chars.shuffle[0, length].join
end

def get_wordset with_dict
  wordset = []
  if with_dict
    wordset = File.readlines('/etc/dictionaries-common/words').collect{|l| l.strip}
  else
    wordset = (0..1000).collect{|n| randstring((n % 8) + 8)}
  end

  return wordset
end

def randtype
  return [:hash, :array, :string].sample
end


def make_whatev(with_dict, type, depth_limit)
  wordset = get_wordset(with_dict)

  if depth_limit < 1
    type = :string
  end

  if type == :hash
    # start with an empty hash
    whatev = {}

    # control our chance of making subwhatevs in terms of the depth_limit
    # add the +1 to make sure that counter is never 1 (i.e. there is always a
    # chance for a subwhatev)
    counter = depth_limit / 2 + 1

    # 1/counter chance we make a sub-whatev, low chance we step on our own toes and
    # overwrite something
    while rand(counter) > 0
      whatev[wordset.sample] = make_whatev(with_dict, randtype, depth_limit-1)
      counter = counter - 1
    end
  elsif type == :array
    # start with an empty array
    whatev = []

    # control our chance of making subwhatevs in terms of the depth_limit
    # done as above
    counter = depth_limit / 2 + 1

    # append until we miss on a 1/counter chance
    while rand(counter) > 0
      whatev << make_whatev(with_dict, randtype, depth_limit-1)

      counter = counter - 1
    end
  elsif type == :string
    whatev = wordset.sample
  end

  return whatev
end

def print_whatev thewhatev
  outstyle = rand(25)
  # print as a raw hash. Ew
  if outstyle == 0
    puts thewhatev.to_s
  # print out hash contents as json, or maybe the empty string. Also Ew
  elsif outstyle == 1
    thewhatev.each_pair do |key, val|
      puts val.to_json.to_s
    end
  # print out hash values as json elements of an array. Also Ew
  elsif outstyle == 2
    tempwhatev = []
    thewhatev.each_pair do |key, val|
      tempwhatev << val
    end
    puts tempwhatev.to_json.to_s
  # regular JSON whatev printing
  else
    puts thewhatev.to_json.to_s
  end
end


print_whatev make_whatev(true, :hash, 10)
