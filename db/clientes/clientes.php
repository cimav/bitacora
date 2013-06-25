<?php
$f = file('clientes.txt');
foreach ($f as $l) {
  $id = trim(substr($l, 4, 4));
  if (($id * 1) > 0) {
    $name = trim(substr($l, 11));
    print "INSERT INTO clientes VALUES('$id','$name');\n";
    $prev_id = $id;
  } else {
    $contacto = trim(substr($l,14,40));
    $mail = trim(substr($l,56));
    print "INSERT INTO contactos VALUES('$prev_id','$contacto','$mail');\n";
  }
}
