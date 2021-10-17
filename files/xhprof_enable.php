<?php
$g_xhprof_limit_ms = isset($_GET['xhprof'])?0:3000;
xhprof_enable();

register_shutdown_function(function() {
    global $g_xhprof_limit_ms;
    $data = xhprof_disable();
    $ms = intval($data['main()']['wt']/1000);
    @header('X-xhprof: '.$ms);
    if (function_exists('fastcgi_finish_request')){
        fastcgi_finish_request();
    }
    if ($g_xhprof_limit_ms == 0 || $ms >= $g_xhprof_limit_ms) {
        include_once "/var/www/xhprof/xhprof_lib/utils/xhprof_lib.php";
        include_once "/var/www/xhprof/xhprof_lib/utils/xhprof_runs.php";
        $xhprof_runs = new XHProfRuns_Default();
        $run_id = $xhprof_runs->save_run($data, $ms);
    }
});