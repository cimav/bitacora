class LaboratoriesOverviewController < ApplicationController
  def index
  	
  	q0 = "SELECT laboratories.id AS laboratory_id, business_units.name AS sede, laboratories.name AS laboratorio FROM laboratories LEFT JOIN business_units ON business_unit_id = business_units.id  ORDER BY business_units.name, laboratories.name"
  	q1 = "SELECT laboratory_id, COUNT(*) AS cuantos FROM requested_services LEFT JOIN samples ON sample_id = samples.id LEFT JOIN laboratory_services ON laboratory_service_id = laboratory_services.id WHERE requested_services.status IN (31, 2,3,6) GROUP BY laboratory_id"
  	q2 = "SELECT laboratory_id, COUNT(*) AS retrasados FROM requested_services LEFT JOIN samples ON sample_id = samples.id LEFT JOIN laboratory_services ON laboratory_service_id = laboratory_services.id WHERE requested_services.status IN (31, 2,3,6) AND results_date > NOW() GROUP BY laboratory_id"
  	q3 = "SELECT laboratory_id, AVG(DATEDIFF(CONCAT(results_date,' 23:59:00'), received_date)) AS tiempo_esperado FROM requested_services LEFT JOIN laboratory_services ON laboratory_service_id = laboratory_services.id WHERE finished_date IS NOT NULL AND received_date IS NOT NULL AND results_date IS NOT NULL AND requested_services.status IN(99,100) AND results_date > received_date GROUP BY laboratory_id"
  	q4 = "SELECT laboratory_id, AVG(DATEDIFF(finished_date, received_date)) AS tiempo_real FROM requested_services LEFT JOIN laboratory_services ON laboratory_service_id = laboratory_services.id WHERE finished_date IS NOT NULL AND received_date IS NOT NULL AND results_date IS NOT NULL AND requested_services.status IN(99,100) GROUP BY laboratory_id"
    
    sql = "SELECT sede, laboratorio, cuantos, retrasados, tiempo_esperado, tiempo_real FROM (#{q0}) AS n LEFT JOIN (#{q1}) AS a ON n.laboratory_id = a.laboratory_id LEFT JOIN (#{q2}) AS b ON a.laboratory_id = b.laboratory_id LEFT JOIN (#{q3}) AS c ON a.laboratory_id = c.laboratory_id LEFT JOIN (#{q4}) AS d ON a.laboratory_id = d.laboratory_id ORDER BY sede, laboratorio"


  	@overview = ActiveRecord::Base.connection.execute(sql)
    render :layout => false
  end
end
