class VinculacionFile < ActiveRecord::Base
  self.table_name = "sigre_production.vinculacion_archivos"
  mount_uploader :archivo, VinculacionFileUploader

  ARCHIVO_CLIENTE = 1
  ORDEN_DE_COMPRA = 2

  TIPO = {
    ARCHIVO_CLIENTE => "Archivo del cliente",
    ORDEN_DE_COMPRA => "Orden de compra" 
  }

  def tipo_text
    TIPO[tipo_archivo]
  end

end