<html>
    <head>
        <script type="text/javascript" src="http://<?php echo $_SERVER['HTTP_HOST']; ?>/script.js"></script>
    </head>
    <body>
        <h1>Vulnerable web app</h1>
        <form action="search.php">
            <label for="product_name">Product name:</label>
              <input type="text" id="product_name" name="product_name"><br><br>
        </form>
    </body>
</html>
