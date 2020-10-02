class SurveyMailer
  @queue = :mail

  def self.perform(requested_service_id, user_id)
    requested_service = RequestedService.find(requested_service_id)
    survey = requested_service.requested_service_surveys.first
    puts "SURVEY"
    puts survey 
    puts "-----------------------"
    puts "Surveysss"
    puts requested_service.requested_service_surveys
    puts "ooooooooooooooooooooooo"
    user = User.find(user_id)
    BitacoraMailer.send_survey(requested_service, user, survey).deliver 
  end

end
