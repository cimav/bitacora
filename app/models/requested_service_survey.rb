class RequestedServiceSurvey < ActiveRecord::Base
  attr_accessible :requested_service_id, :q1, :q2, :q3, :q4, :q5
  belongs_to :requested_service

  RATING_1 = 1
  RATING_2 = 2
  RATING_3 = 3
  RATING_4 = 4
  RATING_5 = 5

  QUESTION_1 = 1
  QUESTION_2 = 2
  QUESTION_3 = 3
  QUESTION_4 = 4
  QUESTION_5 = 5


  SCALE = {
  	RATING_1 => 'Insuficiente',
  	RATING_2 => 'Regular',
  	RATING_3 => 'Bueno',
  	RATING_4 => 'Muy bueno',
  	RATING_5 => 'Excelente'
  }

  QUESTIONS = {
  	QUESTION_1 => 'Reporte o resultados que le fueron entregados',
  	QUESTION_2 => 'Atención del técnico',
  	QUESTION_3 => 'Tiempo de respuesta'
  }
end
