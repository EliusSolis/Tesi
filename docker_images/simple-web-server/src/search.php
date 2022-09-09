<?php
    $host        = "host = postgres";
    $port        = "port = 5432";
    $dbname      = "dbname = webapp";
    $credentials = "user = frontend password = frontend";

    $db = pg_connect("$host $port $dbname $credentials");
    if(!$db) {
        echo "Error : Unable to open database\n";
    } else {
        $product_name = $_GET['product_name'];
        $sql = "SELECT * from product WHERE name = '$product_name'";
        $ret = pg_query($db, $sql);
        if ($ret) {
            echo "Query executed correctly";
            $rows = pg_fetch_all($ret);
            echo "<table>";
            foreach ($rows as $row) {
                echo "<tr>";
                foreach ($row as $value) {
                    echo "<td>$value</td>";
                }
                echo "</tr>";
            }
            echo "</table>";
        } else {
            echo "There was a problem with your query";
        }
        pg_close($db);
   }
?>
