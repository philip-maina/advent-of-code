module CryptographicHandshake
  attr_accessor :public_key,
                :encryption_key
  
  def initialize(public_key:)
    @public_key     = public_key
    @encryption_key = nil
  end

  def generate_encryption_key(public_key:)
    @encryption_key = transform_subject_no(subject_no: public_key)
  end

  def transform_subject_no(subject_no:)
    loop_size.times.reduce(1) { |acc, _| (acc * subject_no) % 20201227 }
  end

  def loop_size
    return @loop_size if @loop_size

    @loop_size  = 0
    value       = 1
    subject_no  = 7

    while (value != public_key)
      value = (value * subject_no) % 20201227
      @loop_size += 1
    end

    @loop_size
  end
end

module Room
  class Door
    include CryptographicHandshake
  end

  class KeyCard
    include CryptographicHandshake
  end
end

class ComboBreaker
  def self.run!
    door     = Room::Door.new(public_key: 2084668)
    key_card = Room::KeyCard.new(public_key: 3704642)

    door.generate_encryption_key(public_key: key_card.public_key)
    key_card.generate_encryption_key(public_key: door.public_key)

    puts door.encryption_key
    puts key_card.encryption_key
  end
end

ComboBreaker.run!




