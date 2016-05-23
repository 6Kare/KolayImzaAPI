<?php
function getUrl($query)
{
    return 'http://' . $_SERVER["HTTP_HOST"] . '/api/file.php?' . $query;
}

$op = isset($_GET['op']) ? $_GET['op'] : '';
$id = isset($_GET['id']) ? $_GET['id'] : '';

switch ($op) {
case '':
    if (file_exists('./sig.json'))
      unlink('./sig.json');
    break;
case 'wait':
    ob_start();
    echo '<html>';
    echo '<body>';    
    if (file_exists('./sig.json')) {
      echo 'imza alındı';
      echo '<script>';
      echo "alert('" . file_get_contents('./sig.json') . "');";
      echo "window.location = '" . getUrl('') ."';";
      echo '</script>';
    } else {
      echo 'imza bekleniyor';
      sleep(3);
      flush();
      echo '<script>';      
      echo "window.location = 'http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]';";
      echo '</script>';
    }    
    echo '</body></html>';
    return;
    break;
case 'request':
    header('Content-type: application/json');
    echo '{';
    echo '  "id":' . $id . ',';
    echo '  "resources": [';
    echo '    {';
    echo '    "source" : "' . getUrl("id=" . $id . "&op=content") . '",';
    echo '    "sourceName" : "sample.txt"';
    echo '    }';
    echo '  ],';
    echo '  "responseUrl": "' . getUrl("id=" . $id . "&op=response") . '"';
    echo '}';
    return;
    break;
case 'content':
    header('Content-type: application/octet-stream');
    echo "hello";
    return;
    break;
case 'response':
    $data = file_get_contents('php://input');
    json_decode($data); // ensure json
    file_put_contents('./sig.json', $data);
    return;
    break;
}

?>
<html>
<head>
    <script src="https://code.jquery.com/jquery-git.min.js" type="text/javascript"></script>
</head>
<body>
    <a href="#" class="imzala">İmzala</a>
    <script type="text/javascript">
        $(document).ready(function() {
            $('a.imzala').on('click', function () {
                $('<iframe></iframe>').appendTo('body').attr('src', 'sign://?xs=<?=getUrl(urlencode("id=123&op=request"))?>');
                window.location.href = '<?=getUrl("id=123&op=wait")?>';
            });
        });
    </script>
</body>
</html>