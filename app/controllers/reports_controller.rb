class ReportsController < ApplicationController

  def index
  	render :layout => false
  end

  def eficiencia
  	drop_temp_table = "DROP TABLE IF EXISTS rep1"
  	create_temp_table = "CREATE TEMPORARY TABLE rep1
                         SELECT
                         laboratory_id,
                         requested_service_id,
                         number,
                         laboratory_service_id,
                         requested_services.user_id,
                         MAX(CASE WHEN requested_service_status = 1 THEN activity_logs.created_at END) ST1,
                         MAX(CASE WHEN requested_service_status = 2 THEN activity_logs.created_at END) ST2,
                         MAX(CASE WHEN requested_service_status = 3 THEN activity_logs.created_at END) ST3,
                         MAX(CASE WHEN requested_service_status = 4 THEN activity_logs.created_at END) ST4,
                         MAX(CASE WHEN requested_service_status = 5 THEN activity_logs.created_at END) ST5,
                         MAX(CASE WHEN requested_service_status = 6 THEN activity_logs.created_at END) ST6,
                         MAX(CASE WHEN requested_service_status = 7 THEN activity_logs.created_at END) ST7,
                         MAX(CASE WHEN requested_service_status = 8 THEN activity_logs.created_at END) ST8,
                         MAX(CASE WHEN requested_service_status = 99 THEN activity_logs.created_at END) ST99
                         FROM requested_services
                         LEFT JOIN laboratory_services ON laboratory_service_id = laboratory_services.id
                         LEFT JOIN activity_logs ON activity_logs.requested_service_id = requested_services.id
                         WHERE
                         laboratory_id = 24 AND
                         requested_services.updated_at BETWEEN '2013-01-01' AND '2013-12-31' AND
                         requested_services.status = 99
                         GROUP BY activity_logs.requested_service_id"

    report1 = "SELECT 
                 user_id, 
                 CONCAT(first_name, ' ', last_name) AS nombre, 
                 AVG(TIMESTAMPDIFF(HOUR, ST1,ST2))/24 tiempo_recibir, 
                 AVG(TIMESTAMPDIFF(HOUR, ST2,ST3))/24 tiempo_asignar, 
                 AVG(TIMESTAMPDIFF(HOUR, ST3,ST6))/24 tiempo_iniciar_proceso, 
                 AVG(TIMESTAMPDIFF(HOUR, ST6,ST99))/24 tiempo_finalizar, 
                 AVG(TIMESTAMPDIFF(HOUR, ST1,ST99))/24 tiempo_total 
               FROM 
                 rep1 
                 LEFT JOIN users ON user_id = users.id 
               WHERE ST4 IS NULL 
               GROUP BY user_id 
               ORDER BY nombre"

    result = ActiveRecord::Base.connection.execute(drop_temp_table)
    result = ActiveRecord::Base.connection.execute(create_temp_table)
    @report1 = ActiveRecord::Base.connection.execute(report1)
  	render :layout => false
  end

end
