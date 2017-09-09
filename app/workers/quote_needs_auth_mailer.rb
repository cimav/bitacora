class QuoteNeedsAuthMailer
  @queue = :mail

  def self.perform(requested_service_id, user_id)
    BitacoraMailer.quote_needs_auth(requested_service_id, user_id).deliver 
  end

end