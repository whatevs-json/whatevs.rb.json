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
    counter = depth_limit

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
    counter = depth_limit

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


puts make_whatev(true, :hash, 10).to_json.to_s
