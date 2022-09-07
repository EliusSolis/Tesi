<?php
    $host        = "host = 192.168.80.9";
    $port        = "port = 5432";
    $dbname      = "dbname = webapp";
    $credentials = "user = frontend";

    $db = pg_connect("$host $port $dbname $credentials");
    if(!$db) {
        echo "Error : Unable to open database\n";
    } else {
        $sql = "SELECT * from product WHERE name = $_GET['product_name']";
        $ret = pg_query($db, $sql)
        if ($ret) {
            echo "Query executed correctly";
        } else {
            echo "There was a problem with your query";
        }
        pg_close($db);
   }
?>
