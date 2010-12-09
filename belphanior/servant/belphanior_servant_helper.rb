module BelphaniorServantHelper
  def self.text_out_as_json(text_representation, status=200)
    [status, {"Content-Type" => "application/json"}, text_representation]
  end
end
