<?php
declare(strict_types=1);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

spl_autoload_register(function (string $class): void {
    $prefix = 'App\\';
    if (!str_starts_with($class, $prefix)) {
        return;
    }
    $relativeClass = substr($class, strlen($prefix));
    $file = dirname(__DIR__) . '/src/' . str_replace('\\', '/', $relativeClass) . '.php';
    if (is_file($file)) {
        require_once $file;
    }
});

use App\Config\Database;
use App\Config\Env;
use App\Controllers\AccountController;
use App\Controllers\FamilleMembreController;
use App\Helpers\Response;

Env::load(dirname(__DIR__) . '/.env');

$requestUri = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$scriptDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');

if ($scriptDir !== '' && $scriptDir !== '/' && str_starts_with($requestUri, $scriptDir)) {
    $route = substr($requestUri, strlen($scriptDir));
} else {
    $route = $requestUri;
}

$route = '/' . trim($route, '/');
$method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');

$accountController = new AccountController();
$familleController = new FamilleMembreController();

if ($route === '/health' && $method === 'GET') {
    Database::getConnection();
    Response::success([
        'status' => 'ok',
        'database' => Env::get('DB_DATABASE', 'api'),
        'php_version' => PHP_VERSION,
    ], 'API opérationnelle.');
}

if ($route === '/accounts/register' && $method === 'POST') {
    $accountController->register();
}

if ($route === '/accounts/login' && $method === 'POST') {
    $accountController->login();
}

if ($route === '/famille-membres/stats' && $method === 'GET') {
    $familleController->stats();
}

if ($route === '/famille-membres' && $method === 'GET') {
    $familleController->index();
}

if ($route === '/famille-membres' && $method === 'POST') {
    $familleController->store();
}

if (preg_match('#^/famille-membres/(\d+)$#', $route, $matches)) {
    $id = (int) $matches[1];
    if ($method === 'GET') {
        $familleController->show($id);
    }
    if ($method === 'PUT' || $method === 'POST') {
        $familleController->update($id);
    }
    if ($method === 'DELETE') {
        $familleController->destroy($id);
    }
}

Response::error('Route introuvable', 404);
