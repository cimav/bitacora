INSERT INTO client_contacts SELECT NULL, clients.id, nombre, '', correo, 1, NOW(), NOW() FROM xxx.contactos LEFT JOIN clients ON rfc = xxx.contactos.id;

INSERT INTO contacts SELECT NULL, clients.id, nombre, '', correo, 1, NOW(), NOW() FROM xxx.contactos LEFT JOIN clients ON rfc = xxx.contactos.id;
