class LaboratoryServiceAdditional < ActiveRecord::Base
  belongs_to :laboratory_service

  CHECKBOX = 'checkbox'
  COMBO    = 'combo'
  TEXT     = 'text'
  TEXTAREA = 'textarea'

  TYPES = {
    CHECKBOX  => 'Casilla',
    COMBO     => 'Opción multiple',
    TEXT      => 'Texto',
    TEXTAREA  => 'Área de texto'
  }

  def type_text
    TYPES[access.to_i]
  end

end
