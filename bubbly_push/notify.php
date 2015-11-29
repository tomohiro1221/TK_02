<?php
$deviceToken = "afb5c4ff3c153dbe30a3a04ee168030f5b5d786035f629779ad999af3786a697";

$alert = 'Push test.';

$badge = 1;

$body = array();
$body['aps'] = array('alert' => $alert);
$body['aps']['badge'] = $badge;

$cert = 'server_certificates_sandbox.pem';
$url = 'ssl://gateway.sandbox.push.apple.com:2195';

$context = stream_context_create();
stream_context_set_option($context, 'ssl', 'local_cert', $cert);
$fp = stream_socket_client($url, $err, $errstr, 60, STREAM_CLIENT_CONNECT, $context);

if (!$fp) {
    echo 'Failed to connect.' . PHP_EOL;
    exit(1);
}

$payload = json_encode($body);
$message = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

print 'send message' . $payload . PHP_EOL;

fwrite($fp, $message);
fclose($fp);
?>
