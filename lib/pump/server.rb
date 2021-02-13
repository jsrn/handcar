module Handcar
  class Server
    def initialize(options)
      @options = options
    end

    def serve
      # Extremely bad not good, but currently can't be
      # bothered to do the work required to move routing out of
      # config.ru
      `rackup -p 3000`
    end
  end
end
